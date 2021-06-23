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
    typealias DataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>
    typealias CellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell,
        SidebarItem
    >

    let isCompact: Bool

    init(isCompact: Bool) {
        self.isCompact = isCompact
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cancellables = Set<AnyCancellable>()
    @Published private var animateChanges = false
    let viewModel = RecordsViewModel()

    private lazy var addTerritoryBarButton = makeAddTerritoryBarButton()
    private lazy var addRecordBarButton = makeAddRecordBarButton()

    lazy var collectionView = makeCollectionView()
    lazy var dataSource = makeDataSource()

    let largeSymbolConfig = UIImage.SymbolConfiguration(textStyle: .title3)

    var selectedCollectionCell: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.$recordsSnapshot
            .apply(to: .records, in: dataSource, animate: $animateChanges)
            .store(in: &cancellables)
        viewModel.$territoriesSnapshot
            .apply(to: .territories, in: dataSource, animate: $animateChanges)
            .store(in: &cancellables)
        animateChanges = true

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

        let submitAction = UIAlertAction(
            title: "Save",
            style: .default,
            handler: { [weak self] action in
                if let territory = territory {
                    self?.viewModel.updateTerritory(territory: territory, to: nameTextField?.text)
                } else {
                    self?.viewModel.addTerritory(named: nameTextField?.text)
                }
            }
        )
        alertController.addAction(submitAction)

        if let territory = territory {
            alertController.title = "Edit Territory"
            nameTextField?.text = territory.wrappedName
        }

        present(alertController, animated: true)
    }
}
