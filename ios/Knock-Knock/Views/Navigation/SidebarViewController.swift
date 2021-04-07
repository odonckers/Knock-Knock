//
//  SidebarNavigationViewController.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/3/21.
//

import CoreData
import UIKit

@available(iOS 14, *)
class SidebarViewController: UIViewController {
    private var collectionView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!

    private var viewContext: NSManagedObjectContext!
    private var fetchedTerritoriesController: NSFetchedResultsController<Territory>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        setupToolbar()

        configureCollectionView()

        configureDataSource()

        configureViewContext()
        configureFetchRequests()
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureNavigationBar() {
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setToolbarHidden(false, animated: false)
    }

    private func setupToolbar() {
        let addTerritoryButton = UIBarButtonItem(
            image: UIImage(systemName: "folder.badge.plus"),
            primaryAction: UIAction { [weak self] action in
                guard let self = self else { return }
                self.presentTerritoryForm()
            }
        )
        setToolbarItems(
            [
                UIBarButtonItem(systemItem: .flexibleSpace),
                addTerritoryButton
            ],
            animated: false
        )
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self

        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(
                appearance: .sidebar
            )
            configuration.showsSeparators = false
            configuration.headerMode = sectionIndex == 0
                ? .none
                : .firstItemInSection
            configuration.trailingSwipeActionsConfigurationProvider = {
                [weak self] indexPath in

                guard
                    let self = self,
                    let section = SidebarSection(rawValue: indexPath.section)
                else { return nil }

                switch section {
                case .territories:
                    let editAction = UIContextualAction(
                        style: .normal,
                        title: "Edit"
                    ) { [weak self] action, view, completion in
                        guard let self = self else { return }

                        self.presentTerritoryForm(itemAt: indexPath)
                        completion(true)
                    }
                    editAction.image = UIImage(systemName: "pencil")
                    editAction.backgroundColor = .systemGray2

                    let deleteAction = UIContextualAction(
                        style: .destructive,
                        title: "Delete"
                    ) { [weak self] action, view, completion in
                        guard let self = self else {
                            completion(false)
                            return
                        }

                        let deleteAction = UIAlertAction(
                            title: "Delete",
                            style: .destructive
                        ) { action in
                            self.deleteTerritory(at: indexPath)
                            completion(true)
                        }
                        let cancelAction = UIAlertAction(
                            title: "Cancel",
                            style: .cancel
                        ) { _ in
                            completion(false)
                        }

                        let alert = UIAlertController(
                            title: "Are you sure?",
                            message: "This action is permanent and cannot be undone.",
                            preferredStyle: .alert
                        )
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)

                        self.present(alert, animated: true)
                    }
                    deleteAction.image = UIImage(systemName: "trash")
                    deleteAction.backgroundColor = .systemRed

                    let swipeConfiguration = UISwipeActionsConfiguration(
                        actions: [deleteAction, editAction]
                    )
                    swipeConfiguration.performsFirstActionWithFullSwipe = false
                    return swipeConfiguration
                default:
                    return nil
                }
            }

            let section: NSCollectionLayoutSection = .list(
                using: configuration,
                layoutEnvironment: layoutEnvironment
            )
            return section
        }
        return layout
    }
}

@available(iOS 14, *)
extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath)
        else { return }

        switch indexPath.section {
        case SidebarSection.records.rawValue:
            didSelectRecordsItem(sidebarItem, at: indexPath)
        case SidebarSection.territories.rawValue:
            didSelectTerritoryItem(sidebarItem, at: indexPath)
        default:
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    private func recordsViewController() -> RecordsViewController? {
        guard
            let splitViewController = splitViewController,
            let navigationViewController = splitViewController.viewController(
                for: .supplementary
            ) as? UINavigationController,
            let recordsViewController = navigationViewController.viewControllers.first
        else { return nil }

        return recordsViewController as? RecordsViewController
    }

    private func didSelectRecordsItem(
        _ sidebarItem: SidebarItem,
        at indexPath: IndexPath
    ) {
        if let recordsViewController = recordsViewController() {
            recordsViewController.selectedTerritory = nil
        }
    }

    private func didSelectTerritoryItem(
        _ sidebarItem: SidebarItem,
        at indexPath: IndexPath
    ) {
        guard
            let territory = sidebarItem.object as? Territory,
            let recordsViewController = recordsViewController()
        else { return }

        recordsViewController.selectedTerritory = territory
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem>

    private func configureDataSource() {
        let headerRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }

        let expandableRowRegistration = CellRegistration {
            cell, indexPath, item in

            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            cell.contentConfiguration = contentConfiguration
            cell.accessories = [.outlineDisclosure()]
        }

        let rowRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item.type {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerRegistration,
                    for: indexPath,
                    item: item
                )
            case .expandableRow:
                return collectionView.dequeueConfiguredReusableCell(
                    using: expandableRowRegistration,
                    for: indexPath,
                    item: item
                )
            default:
                return collectionView.dequeueConfiguredReusableCell(
                    using: rowRegistration,
                    for: indexPath,
                    item: item
                )
            }
        }
    }

    private func recordsSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let items: [SidebarItem] = [
            .row(
                title: TabBarItem.records.title,
                subtitle: nil,
                image: TabBarItem.records.image,
                id: RowIdentifier.records
            )
        ]

        snapshot.append(items)
        return snapshot
    }

    private func territoriesSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
        let header: SidebarItem = .header(title: TabBarItem.territories.title)

        var items = [SidebarItem]()
        if let territories = fetchedTerritoriesController.fetchedObjects {
            items = territories.map { territory in
                .row(
                    title: territory.wrappedName,
                    subtitle: nil,
                    image: UIImage(systemName: "folder"),
                    id: territory.wrappedID,
                    object: territory
                )
            }
        }

        snapshot.append([header])
        snapshot.expand([header])
        snapshot.append(items, to: header)
        return snapshot
    }

    private func applyInitialSnapshot() {
        dataSource
            .apply(recordsSnapshot(), to: .records, animatingDifferences: false)
        dataSource.apply(
            territoriesSnapshot(),
            to: .territories,
            animatingDifferences: false
        )

        collectionView.selectItem(
            at: IndexPath(row: 0, section: 0),
            animated: false,
            scrollPosition: .centeredVertically
        )
    }

    private func updateSnapshot() {
        let snapshot = territoriesSnapshot()
        dataSource.apply(snapshot, to: .territories)
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func configureViewContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistenceController.container.viewContext
    }

    private func configureFetchRequests() {
        let fetchRequest: NSFetchRequest = Territory.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ]

        fetchedTerritoriesController = NSFetchedResultsController<Territory>(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedTerritoriesController.delegate = self

        do {
            try fetchedTerritoriesController.performFetch()
            applyInitialSnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }
}

@available(iOS 14, *)
extension SidebarViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        updateSnapshot()
    }
}

@available(iOS 14, *)
extension SidebarViewController {
    private func presentTerritoryForm(itemAt indexPath: IndexPath) {
        let sidebarItem = dataSource.itemIdentifier(for: indexPath)
        guard let territory = sidebarItem?.object as? Territory else { return }
        presentTerritoryForm(territory: territory)
    }

    private func presentTerritoryForm(territory: Territory? = nil) {
        let alertController = UIAlertController(
            title: "New Territory",
            message: nil,
            preferredStyle: .alert
        )

        alertController.addTextField()

        let nameTextField = alertController.textFields?.first
        nameTextField?.placeholder = "Name"
        nameTextField?.autocapitalizationType = .allCharacters

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [unowned alertController] _ in

            guard let textFields = alertController.textFields
            else { return }

            let nameField = textFields[0]

            var toSave: Territory
            if let territory = territory {
                toSave = territory
                toSave.willUpdate()
            } else {
                toSave = Territory(context: self.viewContext)
                toSave.willCreate()
            }

            toSave.name = nameField.text
            self.viewContext.unsafeSave()
        }
        alertController.addAction(submitAction)

        if let territory = territory {
            alertController.title = "Edit Territory"
            alertController.message = territory.wrappedName

            nameTextField?.text = territory.wrappedName
        }

        present(alertController, animated: true)
    }

    private func deleteTerritory(at indexPath: IndexPath) {
        let sidebarItem = dataSource.itemIdentifier(for: indexPath)
        guard let territory = sidebarItem?.object as? Territory else { return }
        deleteTerritory(territory)
    }

    private func deleteTerritory(_ territory: Territory) {
        viewContext.delete(territory)
        viewContext.unsafeSave()
    }
}

@available(iOS 14.0, *)
extension SidebarViewController {
    private enum SidebarItemType: Int {
        case header, expandableRow, row
    }

    private enum SidebarSection: Int {
        case records, territories
    }

    private struct SidebarItem: Hashable, Identifiable {
        let id: String
        let type: SidebarItemType
        let title: String
        let subtitle: String?
        let image: UIImage?
        var object: NSManagedObject?

        static func header(
            title: String,
            id: String = UUID().uuidString
        ) -> Self {
            SidebarItem(
                id: id,
                type: .header,
                title: title,
                subtitle: nil,
                image: nil,
                object: nil
            )
        }

        static func expandableRow(
            title: String,
            subtitle: String?,
            image: UIImage?,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> Self {
            SidebarItem(
                id: id,
                type: .expandableRow,
                title: title,
                subtitle: subtitle,
                image: image,
                object: object
            )
        }

        static func row(
            title: String,
            subtitle: String?,
            image: UIImage?,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> Self {
            SidebarItem(
                id: id,
                type: .row,
                title: title,
                subtitle: subtitle,
                image: image,
                object: object
            )
        }
    }

    private struct RowIdentifier {
        static let records = UUID().uuidString
    }
}
