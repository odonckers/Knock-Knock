//
//  SidebarNavigationViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/3/21.
//

import Combine
import CoreData
import SwiftUI
import UIKit

class SidebarViewController: UIViewController {
    private var collectionView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>!

    private var moc: NSManagedObjectContext!
    private var fetchedRecordsController: NSFetchedResultsController<Record>!
    private var fetchedTerritoriesController: NSFetchedResultsController<Territory>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureCollectionView()

        configureDataSource()

        configureViewContext()

        configureRecordFetchRequest()
        configuredTerritoryFetchRequest()
    }
}

// MARK: - Top Bar

extension SidebarViewController {
    private func configureNavigationBar() {
        title = "Records"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addRecordButton = UIBarButtonItem(
            title: "Add Record",
            image: UIImage(systemName: "plus.circle.fill"),
            menu: UIMenu(
                children: [
                    UIAction(
                        title: "Add Record",
                        image: UIImage(systemName: "note.text.badge.plus")
                    ) { [weak self] action in
                        guard let self = self else { return }

                        let navigationController = UINavigationController()
                        navigationController.modalPresentationStyle = .formSheet

                        RecordFormView()
                            .environment(\.managedObjectContext, self.moc)
                            .environment(\.uiNavigationController, navigationController)
                            .assignToUI(navigationController: navigationController)

                        self.present(navigationController, animated: true)
                    },
                    UIAction(
                        title: "Add Territory",
                        image: UIImage(systemName: "folder.fill.badge.plus")
                    ) { [weak self] action in
                        self?.presentTerritoryForm()
                    }
                ]
            )
        )
        navigationItem.setRightBarButtonItems([addRecordButton], animated: false)
    }
}

// MARK: - Collection Layout

extension SidebarViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(appearance: .sidebar)
            configuration.showsSeparators = false
            configuration.headerMode = sectionIndex == 0 ? .none : .firstItemInSection
            configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let item = self?.dataSource.itemIdentifier(for: indexPath)
                else { return nil }

                switch item.object {
                case is Territory: return self?.territoryLeadingSwipeActions(at: indexPath)
                default: return nil
                }
            }
            configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let item = self?.dataSource.itemIdentifier(for: indexPath)
                else { return nil }

                switch item.object {
                case is Record: return self?.recordTrailingSwipeActions(at: indexPath)
                case is Territory: return self?.territoryTrailingSwipeActions(at: indexPath)
                default: return nil
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

    private func recordTrailingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] action, view, completion in

            guard let self = self else {
                completion(false)
                return
            }

            self.updateRecord(at: indexPath)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemGray2

        let moveAction = UIContextualAction(style: .normal, title: "Move") {
            [weak self] action, view, completion in

            guard let self = self else {
                completion(false)
                return
            }

            self.moveRecord(at: indexPath)
            completion(true)
        }
        moveAction.image = UIImage(systemName: "folder.fill")
        moveAction.backgroundColor = .systemIndigo

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] action, view, completion in

            guard let self = self else {
                completion(false)
                return
            }

            self.verifyRecordDeletion(
                at: indexPath,
                displaced: true,
                completion: completion
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed

        let swipeConfiguration = UISwipeActionsConfiguration(
            actions: [deleteAction, moveAction, editAction]
        )
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }

    private func territoryLeadingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let addAction = UIContextualAction(style: .normal, title: "Add Record") {
            [weak self] action, view, completion in

            guard
                let self = self,
                let item = self.dataSource.itemIdentifier(for: indexPath),
                let territory = item.object as? Territory
            else {
                completion(false)
                return
            }

            let navigationController = UINavigationController()
            navigationController.modalPresentationStyle = .formSheet

            RecordFormView(territory: territory)
                .environment(\.managedObjectContext, self.moc)
                .environment(\.uiNavigationController, navigationController)
                .assignToUI(navigationController: navigationController)

            self.present(navigationController, animated: true)

            completion(true)
        }
        addAction.image = UIImage(systemName: "plus")
        addAction.backgroundColor = .accentColor

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [addAction])
        return swipeConfiguration
    }

    private func territoryTrailingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            [weak self] action, view, completion in

            guard let self = self else {
                completion(false)
                return
            }

            self.presentTerritoryForm(itemAt: indexPath)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = .systemGray2

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] action, view, completion in

            guard let self = self else {
                completion(false)
                return
            }

            self.verifyTerritoryDeletion(
                at: indexPath,
                displaced: true,
                completion: completion
            )
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
}

// MARK: - Collection View Delegate

extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sidebarItem = dataSource.itemIdentifier(for: indexPath)
        else { return }

        switch sidebarItem.object {
        case nil: didSelectRecordsItem(sidebarItem, at: indexPath)
        case is Record: didSelectRecordItem(sidebarItem, at: indexPath)
        default: break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath)
        else { return nil }

        switch item.object {
        case is Record: return recordContextMenu(at: indexPath)
        case is Territory: return territoryContextMenu(at: indexPath)
        default: return nil
        }
    }

    private func recordsViewController() -> RecordsViewController? {
        guard
            let splitViewController = splitViewController,
            let navigationViewController = splitViewController
                .viewController(for: .supplementary) as? UINavigationController,
            let recordsViewController = navigationViewController.viewControllers.first
        else { return nil }

        return recordsViewController as? RecordsViewController
    }

    private func didSelectRecordsItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        if let recordsViewController = recordsViewController() {
            recordsViewController.selectedTerritory = nil
        }
    }

    private func didSelectRecordItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let record = item.object as? Record
        else { return }

        let doorsView = DoorsView(record: record)
            .environment(\.managedObjectContext, moc)

        let navigationController = UINavigationController()
        navigationController.navigationItem.largeTitleDisplayMode = .never

        doorsView
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        showDetailViewController(navigationController, sender: nil)

        view.window?.windowScene?.title = record.wrappedStreetName
    }

    private func didSelectTerritoryItem(_ sidebarItem: SidebarItem, at indexPath: IndexPath) {
        guard
            let territory = sidebarItem.object as? Territory,
            let recordsViewController = recordsViewController()
        else { return }

        recordsViewController.selectedTerritory = territory
    }
}

// MARK: - Popups

extension SidebarViewController {
    private func recordContextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration {
        let contextMenuConfig = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { actions in
            UIMenu(
                children: [
                    UIMenu(
                        title: "Edit...",
                        options: .displayInline,
                        children: [
                            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) {
                                [weak self] action in

                                self?.updateRecord(at: indexPath)
                            },
                            UIAction(title: "Move", image: UIImage(systemName: "folder")) {
                                [weak self] action in

                                self?.moveRecord(at: indexPath)
                            },
                        ]
                    ),
                    UIAction(
                        title: "Delete",
                        image: UIImage(systemName: "trash"),
                        attributes: .destructive
                    ) { [weak self] action in
                        self?.verifyRecordDeletion(at: indexPath)
                    },
                ]
            )
        }
        return contextMenuConfig
    }

    private func verifyRecordDeletion(
        at indexPath: IndexPath,
        displaced: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let alertController = UIAlertController(
            title: "Are you sure?",
            message: "This action is permanent and cannot be undone.",
            preferredStyle: .actionSheet
        )
        alertController.view.tintColor = .accentColor

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteRecord(at: indexPath)
            completion(true)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            completion(false)
        }
        alertController.addAction(cancelAction)

        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            alertController.popoverPresentationController?.sourceView = selectedCell
            alertController.popoverPresentationController?.sourceRect = selectedCell
                .bounds
                .offsetBy(dx: displaced ? selectedCell.bounds.width : 0, dy: 0)
        }

        present(alertController, animated: true)
    }

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
        alertController.view.tintColor = .accentColor

        alertController.addTextField()

        let nameTextField = alertController.textFields?.first
        nameTextField?.placeholder = "Name"
        nameTextField?.autocapitalizationType = .allCharacters

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)

        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, unowned alertController] action in

            guard let textFields = alertController.textFields else { return }

            let nameField = textFields[0].text
            if let territory = territory {
                self?.updateTerritory(territory: territory, to: nameField)
            } else {
                self?.addTerritory(named: nameField)
            }
        }
        alertController.addAction(submitAction)

        if let territory = territory {
            alertController.title = "Edit Territory"
            alertController.message = territory.wrappedName

            nameTextField?.text = territory.wrappedName
        }

        present(alertController, animated: true)
    }

    private func territoryContextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration {
        let contextMenuConfig = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { actions in
            UIMenu(
                children: [
                    UIAction(title: "Add Record", image: UIImage(systemName: "plus")) {
                        [weak self] action in

                        guard
                            let self = self,
                            let item = self.dataSource.itemIdentifier(for: indexPath),
                            let territory = item.object as? Territory
                        else { return }

                        let navigationController = UINavigationController()
                        navigationController.modalPresentationStyle = .formSheet

                        RecordFormView(territory: territory)
                            .environment(\.managedObjectContext, self.moc)
                            .environment(\.uiNavigationController, navigationController)
                            .assignToUI(navigationController: navigationController)

                        self.present(navigationController, animated: true)
                    },
                    UIMenu(
                        title: "Edit...",
                        options: .displayInline,
                        children: [
                            UIAction(title: "Edit", image: UIImage(systemName: "pencil")) {
                                [weak self] action in

                                self?.presentTerritoryForm(itemAt: indexPath)
                            },
                            UIAction(
                                title: "Delete",
                                image: UIImage(systemName: "trash"),
                                attributes: .destructive
                            ) { [weak self] action in
                                self?.verifyTerritoryDeletion(at: indexPath)
                            },
                        ]
                    ),
                ]
            )
        }
        return contextMenuConfig
    }

    private func verifyTerritoryDeletion(
        at indexPath: IndexPath,
        displaced: Bool = false,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        let alertController = UIAlertController(
            title: "Are you sure?",
            message: "This action is permanent and cannot be undone.",
            preferredStyle: .actionSheet
        )
        alertController.view.tintColor = .accentColor

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteTerritory(at: indexPath)
            completion(true)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            completion(false)
        }
        alertController.addAction(cancelAction)

        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            alertController.popoverPresentationController?.sourceView = selectedCell
            alertController.popoverPresentationController?.sourceRect = selectedCell
                .bounds
                .offsetBy(dx: displaced ? selectedCell.bounds.width : 0, dy: 0)
        }

        present(alertController, animated: true)
    }
}

// MARK: - Collection Cell Registration & Snapshots

extension SidebarViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell,
        SidebarItem
    >

    private func configureDataSource() {
        let headerRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title

            cell.tintColor = item.tintColor

            cell.contentConfiguration = contentConfiguration
            if item.hasExpander ?? false { cell.accessories = [.outlineDisclosure()] }
        }

        let expandableRowRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            cell.tintColor = item.tintColor

            cell.contentConfiguration = contentConfiguration
            if item.hasExpander ?? false { cell.accessories = [.outlineDisclosure()] }
        }

        let rowRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            cell.tintColor = item.tintColor

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
        var items = [SidebarItem]()

        if let records = fetchedRecordsController.fetchedObjects {
            items = records.map { record in
                var subtitle = [String]()
                if let city = record.city { subtitle.append(city) }
                if let state = record.state { subtitle.append(state) }

                return .row(
                    title: record.wrappedStreetName,
                    subtitle: subtitle.joined(separator: ", "),
                    image: UIImage(
                        systemName: record.wrappedType == .apartment
                            ? "a.square.fill"
                            : "s.square.fill"
                    ),
                    tintColor: UIColor(
                        record.wrappedType == .apartment
                            ? .recordTypeApartment
                            : .recordTypeStreet
                    ),
                    id: record.wrappedID,
                    object: record
                )
            }
        }

        snapshot.append(items)
        return snapshot
    }

    private func territoriesSnapshot() -> NSDiffableDataSourceSectionSnapshot<SidebarItem> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()

        let header: SidebarItem = .header(title: TabBarItem.territories.title, hasExpander: false)
        snapshot.append([header])
        snapshot.expand([header])

        if let territories = fetchedTerritoriesController.fetchedObjects {
            territories.forEach { territory in
                let expandableRow: SidebarItem = .expandableRow(
                    title: territory.wrappedName,
                    subtitle: nil,
                    image: UIImage(systemName: "folder"),
                    id: territory.wrappedID,
                    object: territory
                )

                let items: [SidebarItem] = territory.recordArray.map { record in
                    var subtitle = [String]()
                    if let city = record.city { subtitle.append(city) }
                    if let state = record.state { subtitle.append(state) }

                    return .row(
                        title: record.wrappedStreetName,
                        subtitle: subtitle.joined(separator: ", "),
                        image: UIImage(
                            systemName: record.wrappedType == .apartment
                                ? "a.square.fill"
                                : "s.square.fill"
                        ),
                        tintColor: UIColor(
                            record.wrappedType == .apartment
                                ? .recordTypeApartment
                                : .recordTypeStreet
                        ),
                        id: record.wrappedID,
                        object: record
                    )
                }

                snapshot.append([expandableRow], to: header)
                snapshot.expand([expandableRow])
                snapshot.append(items, to: expandableRow)
            }
        }

        return snapshot
    }

    private func updatedTerritoriesSnapshot() {
        let snapshot = territoriesSnapshot()
        dataSource.apply(snapshot, to: .territories)
    }
}

// MARK: - Persistence Controller & Fetch Requests

extension SidebarViewController {
    private func configureViewContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistenceController.container.viewContext
    }

    private func configureRecordFetchRequest() {
        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "territory == NULL")

        fetchedRecordsController = NSFetchedResultsController<Record>(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedRecordsController.delegate = self

        do {
            try fetchedRecordsController.performFetch()
            dataSource.apply(recordsSnapshot(), to: .records, animatingDifferences: false)
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }

    private func configuredTerritoryFetchRequest() {
        let fetchRequest: NSFetchRequest = Territory.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ]

        fetchedTerritoriesController = NSFetchedResultsController<Territory>(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedTerritoriesController.delegate = self

        do {
            try fetchedTerritoriesController.performFetch()
            dataSource.apply(territoriesSnapshot(), to: .territories, animatingDifferences: false)
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }
}

// MARK: - Fetched Results Controller Delegate

extension SidebarViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        switch controller.fetchRequest.entity {
        case Record.entity():
            let snapshot = recordsSnapshot()
            dataSource.apply(snapshot, to: .records, animatingDifferences: true)
        case Territory.entity():
            let snapshot = territoriesSnapshot()
            dataSource.apply(snapshot, to: .territories, animatingDifferences: true)
        default:
            break
        }

    }
}

// MARK: - CRUD

extension SidebarViewController {
    private func moveRecord(at indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let record = item.object as? Record
        else { return }
        moveRecord(record)
    }

    private func moveRecord(_ record: Record) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet

        MoveRecordView(record: record)
            .environment(\.managedObjectContext, self.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }

    private func updateRecord(at indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let record = item.object as? Record
        else { return }
        updateRecord(record)
    }

    private func updateRecord(_ record: Record) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet

        RecordFormView(record: record, territory: record.territory)
            .environment(\.managedObjectContext, self.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }

    private func deleteRecord(at indexPath: IndexPath) {
        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let record = item.object as? Record
        else { return }
        deleteRecord(record)
    }

    private func deleteRecord(_ record: Record) {
        moc.delete(record)
        moc.unsafeSave()
    }

    private func addTerritory(named name: String?) {
        let toSave = Territory(context: self.moc)
        toSave.willCreate()
        toSave.name = name
        self.moc.unsafeSave()
    }

    private func updateTerritory(territory: Territory, to name: String?) {
        territory.willUpdate()
        territory.name = name
        self.moc.unsafeSave()
    }

    private func deleteTerritory(at indexPath: IndexPath) {
        let sidebarItem = dataSource.itemIdentifier(for: indexPath)
        guard let territory = sidebarItem?.object as? Territory else { return }
        deleteTerritory(territory)
    }

    private func deleteTerritory(_ territory: Territory) {
        moc.delete(territory)
        moc.unsafeSave()
    }
}

// MARK: - Enums, Structs, etc.

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
        let title: String?
        let subtitle: String?
        let image: UIImage?
        let hasExpander: Bool?
        let tintColor: UIColor?
        let object: NSManagedObject?

        static func header(
            title: String,
            hasExpander: Bool = true,
            id: String = UUID().uuidString
        ) -> SidebarItem {
            SidebarItem(
                id: id,
                type: .header,
                title: title,
                subtitle: nil,
                image: nil,
                hasExpander: hasExpander,
                tintColor: nil,
                object: nil
            )
        }

        static func expandableRow(
            title: String,
            subtitle: String?,
            image: UIImage?,
            hasExpander: Bool = true,
            tintColor: UIColor? = nil,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> SidebarItem {
            SidebarItem(
                id: id,
                type: .expandableRow,
                title: title,
                subtitle: subtitle,
                image: image,
                hasExpander: hasExpander,
                tintColor: tintColor,
                object: object
            )
        }

        static func row(
            title: String,
            subtitle: String?,
            image: UIImage?,
            tintColor: UIColor? = nil,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> SidebarItem {
            SidebarItem(
                id: id,
                type: .row,
                title: title,
                subtitle: subtitle,
                image: image,
                hasExpander: nil,
                tintColor: tintColor,
                object: object
            )
        }
    }

    private struct RowIdentifier {
        static let records = UUID().uuidString
    }
}
