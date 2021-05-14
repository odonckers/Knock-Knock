//
//  RecordsViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/3/21.
//

import Combine
import CoreData
import UIKit

class RecordsViewController: UIViewController {
    let isCompact: Bool
    let viewModel: RecordsViewModel

    init(isCompact: Bool) {
        self.isCompact = isCompact

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let moc = appDelegate.persistenceController.container.viewContext

        viewModel = RecordsViewModel(moc: moc)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var cancellables = Set<AnyCancellable>()

    private lazy var addTerritoryBarButton = makeAddTerritoryBarButton()
    private lazy var addRecordBarButton = makeAddRecordBarButton()

    lazy var collectionView = makeCollectionView()
    lazy var dataSource = makeDataSource()

    let largeSymbolConfig = UIImage.SymbolConfiguration(textStyle: .title3)

    var selectedCollectionCell: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()

        title = "Records"
        navigationController?.navigationBar.prefersLargeTitles = true

        toolbarItems = [addTerritoryBarButton, .flexibleSpace(), addRecordBarButton]
        navigationController?.isToolbarHidden = false

        view.addSubview(collectionView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedCollectionCell = selectedCollectionCell {
            collectionView.deselectItem(at: selectedCollectionCell, animated: animated)
            self.selectedCollectionCell = nil
        }
    }
}

extension RecordsViewController {
    private func makeAddTerritoryBarButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: "Add Territory",
            image: UIImage(systemName: "folder.badge.plus"),
            primaryAction: UIAction { [weak self] action in
                self?.presentTerritoryForm()
            }
        )
    }

    private func makeAddRecordBarButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: "Add Record",
            image: UIImage(systemName: "note.text.badge.plus"),
            primaryAction: UIAction { [weak self] action in
                self?.presentRecordFormView()
            }
        )
    }
}

extension RecordsViewController {
    func presentTerritoryForm(from indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let territory = item.object as? Territory
        else { return }
        presentTerritoryForm(territory)
    }

    func presentTerritoryForm(_ territory: Territory? = nil) {
        let alertController = UIAlertController(
            title: "New Territory",
            message: territory == nil ? "Enter a name for this territory." : nil,
            preferredStyle: .alert
        )
        alertController.view.tintColor = .accentColor

        alertController.addTextField { nameTextField in
            nameTextField.placeholder = "Name"
            nameTextField.autocapitalizationType = .allCharacters
        }
        let nameTextField = alertController.textFields?.first

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let submitAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let territory = territory {
                self?.viewModel.updateTerritory(territory: territory, to: nameTextField?.text)
            } else {
                self?.viewModel.addTerritory(named: nameTextField?.text)
            }
        }
        alertController.addAction(submitAction)

        if let territory = territory {
            alertController.title = "Edit Territory"
            nameTextField?.text = territory.wrappedName
        }

        present(alertController, animated: true)
    }
}

extension RecordsViewController {
    private func configureDataSource() {
        dataSource.apply(recordsSnapshot(), to: .records, animatingDifferences: false)
        dataSource.apply(territoriesSnapshot(), to: .territories, animatingDifferences: false)

        viewModel.fetchedRecordsList.contentDidChange
            .sink { [weak self] in
                guard let self = self else { return }

                let snapshot = self.recordsSnapshot()
                self.dataSource.apply(snapshot, to: .records, animatingDifferences: true)
            }
            .store(in: &cancellables)

        viewModel.fetchedTerritoriesList.contentDidChange
            .sink { [weak self] in
                guard let self = self else { return }

                let snapshot = self.territoriesSnapshot()
                self.dataSource.apply(snapshot, to: .territories, animatingDifferences: true)
            }
            .store(in: &cancellables)
    }
}

extension RecordsViewController {
    enum SidebarItemType: Int {
        case header, expandableRow, row
    }

    enum SidebarSection: Int {
        case records, territories
    }

    struct SidebarItem: Hashable, Identifiable {
        let id: String
        private(set) var object: NSManagedObject? = nil
        private(set) var type: SidebarItemType
        private(set) var image: UIImage? = nil
        private(set) var title: String? = nil
        private(set) var subtitle: String? = nil
        private(set) var tintColor: UIColor? = nil
        private(set) var hasExpander: Bool = false
        private(set) var hasChild: Bool = false

        static func header(
            title: String,
            hasExpander: Bool = true,
            id: String = UUID().uuidString
        ) -> Self {
            SidebarItem(id: id, type: .header, title: title, hasExpander: hasExpander)
        }

        static func expandableRow(
            image: UIImage? = nil,
            title: String,
            subtitle: String? = nil,
            tintColor: UIColor? = nil,
            hasExpander: Bool = true,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> SidebarItem {
            SidebarItem(
                id: id,
                object: object,
                type: .expandableRow,
                image: image,
                title: title,
                subtitle: subtitle,
                tintColor: tintColor,
                hasExpander: hasExpander
            )
        }

        static func row(
            image: UIImage? = nil,
            title: String,
            subtitle: String? = nil,
            tintColor: UIColor? = nil,
            hasChild: Bool = false,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> SidebarItem {
            SidebarItem(
                id: id,
                object: object,
                type: .row,
                image: image,
                title: title,
                subtitle: subtitle,
                tintColor: tintColor,
                hasChild: hasChild
            )
        }
    }
}
