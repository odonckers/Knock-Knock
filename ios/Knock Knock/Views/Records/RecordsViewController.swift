//
//  RecordsViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/23/21.
//

import CoreData
import SwiftUI
import UIKit

class RecordsViewController: UIViewController {
    var territory: Territory?
    let isCompact: Bool

    init(territory: Territory? = nil, isCompact: Bool = false) {
        self.territory = territory
        self.isCompact = isCompact
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var selectedTerritory: Territory? {
        get { territory }
        set(newValue) {
            territory = newValue
            title = newValue?.wrappedName ?? TabBarItem.records.title
            refreshFetchRequests()
        }
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Record>!

    private var moc: NSManagedObjectContext!
    private var fetchedRecordsController: NSFetchedResultsController<Record>!

    private var sortRecordsButton = UIBarButtonItem(
        title: "Sort",
        image: UIImage(systemName: "arrow.up.arrow.down")
    )
    private var isAscendingRecords = true
    private var selectedSortRecordsKey = "streetName"
    private var sortRecordsKeys: [String: String] = [
        "dateCreated": "Date Created",
        "streetName": "Street Name",
        "city": "City",
        "state": "State",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()

        configureCollectionView()

        configureDataSource()

        configureViewContext()
        configureFetchRequests()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        deselectSelectedIndexPath()
    }

    // BUG FIX for standing collection view deselection not disappearing when returning to view.

    private var selectedIndexPath: IndexPath?

    private func deselectSelectedIndexPath() {
        if let selectedIndexPath = selectedIndexPath {
            self.selectedIndexPath = nil
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
        }
    }
}

extension RecordsViewController {
    private func configureNavigationBar() {
        title = territory?.wrappedName ?? TabBarItem.records.title
        navigationController?.navigationBar.prefersLargeTitles = true

        let addRecordButton = UIBarButtonItem(
            title: "Add Record",
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [weak self] action in
                guard let self = self else { return }

                let navigationController = UINavigationController()
                navigationController.modalPresentationStyle = .formSheet

                RecordFormView(territory: self.territory)
                    .environment(\.managedObjectContext, self.moc)
                    .environment(\.uiNavigationController, navigationController)
                    .assignToUI(navigationController: navigationController)

                self.present(navigationController, animated: true)
            }
        )

        assignSortRecordsMenu()
        navigationItem.setRightBarButtonItems([addRecordButton, sortRecordsButton], animated: false)
    }

    private func assignSortRecordsMenu() {
        sortRecordsButton.menu = UIMenu(
            title: "Sort By",
            children: [
                UIMenu(
                    options: .displayInline,
                    children: [
                        UIAction(
                            title: "Ascending",
                            image: UIImage(systemName: "arrow.up"),
                            state: isAscendingRecords ? .on : .off,
                            handler: { [weak self] action in
                                self?.isAscendingRecords = true
                                self?.refreshFetchRequests()
                                self?.assignSortRecordsMenu()
                            }
                        ),
                        UIAction(
                            title: "Descending",
                            image: UIImage(systemName: "arrow.down"),
                            state: isAscendingRecords ? .off : .on,
                            handler: { [weak self] action in
                                self?.isAscendingRecords = false
                                self?.refreshFetchRequests()
                                self?.assignSortRecordsMenu()
                            }
                        ),
                    ]
                ),
                UIMenu(
                    options: .displayInline,
                    children: sortRecordsKeys.compactMap { (key, value) in
                        UIAction(
                            title: value,
                            state: key == selectedSortRecordsKey ? .on : .off,
                            handler: { [weak self] action in
                                self?.selectedSortRecordsKey = key
                                self?.refreshFetchRequests()
                                self?.assignSortRecordsMenu()
                            }
                        )
                    }
                ),
            ]
        )
    }
}

extension RecordsViewController {
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self

        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() {
            [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(
                appearance: (self?.isCompact ?? false) ? .plain : .sidebarPlain
            )
            configuration.showsSeparators = true
            configuration.headerMode = .none

            configuration.trailingSwipeActionsConfigurationProvider = { indexPath in
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

            let section: NSCollectionLayoutSection = .list(
                using: configuration,
                layoutEnvironment: layoutEnvironment
            )
            return section
        }
        return layout
    }
}

extension RecordsViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let record = dataSource.itemIdentifier(for: indexPath)
        else { return }

        let doorsView = DoorsView(record: record)
            .environment(\.managedObjectContext, moc)

        if isCompact {
            let doorsHostingController = UIHostingController(rootView: doorsView)
            doorsHostingController.navigationItem.largeTitleDisplayMode = .never

            navigationController?.pushViewController(doorsHostingController, animated: true)
        } else {
            let navigationController = UINavigationController()
            navigationController.navigationItem.largeTitleDisplayMode = .never

            doorsView
                .environment(\.uiNavigationController, navigationController)
                .assignToUI(navigationController: navigationController)

            showDetailViewController(navigationController, sender: nil)
        }

        selectedIndexPath = indexPath

        view.window?.windowScene?.title = record.wrappedStreetName
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let contextMenuConfig = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {
            actions in

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
}

extension RecordsViewController {
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
}

extension RecordsViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<RecordCollectionViewListCell, Record>

    private func configureDataSource() {
        let rowRegistration = CellRegistration { [weak self] cell, indexPath, item in
            cell.record = item
            cell.isInset = self?.isCompact ?? false
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Record>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: rowRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func recordsSnapshot() -> NSDiffableDataSourceSectionSnapshot<Record> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<Record>()

        var items = [Record]()
        if let records = fetchedRecordsController.fetchedObjects {
            items = records
        }

        snapshot.append(items)
        return snapshot
    }

    private func applyInitialSnapshot() {
        dataSource.apply(recordsSnapshot(), to: 0, animatingDifferences: false)
    }

    private func updateSnapshot() {
        let snapshot = recordsSnapshot()
        dataSource.apply(snapshot, to: 0, animatingDifferences: true)
    }
}

extension RecordsViewController {
    private func configureViewContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistenceController.container.viewContext
    }

    private func configureFetchRequests() {
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: selectedSortRecordsKey, ascending: isAscendingRecords)
        ]
        if let territory = territory {
            fetchRequest.predicate = NSPredicate(format: "territory == %@", territory)
        } else {
            fetchRequest.predicate = NSPredicate(format: "territory == NULL")
        }

        fetchedRecordsController = NSFetchedResultsController<Record>(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedRecordsController.delegate = self

        do {
            try fetchedRecordsController.performFetch()
            applyInitialSnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }

    private func refreshFetchRequests() {
        let fetchRequest = fetchedRecordsController.fetchRequest
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: selectedSortRecordsKey, ascending: isAscendingRecords)
        ]
        if let territory = territory {
            fetchRequest.predicate = NSPredicate(format: "territory == %@", territory)
        } else {
            fetchRequest.predicate = NSPredicate(format: "territory == NULL")
        }

        do {
            try fetchedRecordsController.performFetch()
            applyInitialSnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }
}

extension RecordsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        updateSnapshot()
    }
}

extension RecordsViewController {
    private func deleteRecord(at indexPath: IndexPath) {
        guard let record = dataSource.itemIdentifier(for: indexPath)
        else { return }
        deleteRecord(record)
    }

    private func deleteRecord(_ record: Record) {
        moc.delete(record)
        moc.unsafeSave()
    }

    private func moveRecord(at indexPath: IndexPath) {
        guard let record = dataSource.itemIdentifier(for: indexPath)
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
        guard let record = dataSource.itemIdentifier(for: indexPath)
        else { return }
        updateRecord(record)
    }

    private func updateRecord(_ record: Record) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet

        RecordFormView(record: record, territory: territory)
            .environment(\.managedObjectContext, self.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }
}
