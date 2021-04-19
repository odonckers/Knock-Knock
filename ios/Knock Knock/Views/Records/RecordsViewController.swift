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
            collectionView
                .deselectItem(at: selectedIndexPath, animated: true)
        }
    }
}

extension RecordsViewController {
    private func configureNavigationBar() {
        title = territory?.wrappedName ?? TabBarItem.records.title
        navigationController?.navigationBar.prefersLargeTitles = true

        let addRecordButton = UIBarButtonItem(
            title: "Add Record",
            image: UIImage(systemName: "plus.circle.fill"),
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
        navigationItem.rightBarButtonItem = addRecordButton
    }
}

extension RecordsViewController {
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
            [weak self] (
                sectionIndex,
                layoutEnvironment
            ) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(
                appearance: (self?.isCompact ?? false) ? .plain : .sidebarPlain
            )
            configuration.showsSeparators = true
            configuration.headerMode = .none

            configuration.trailingSwipeActionsConfigurationProvider = {
                indexPath in

                let editAction = UIContextualAction(
                    style: .normal,
                    title: "Edit"
                ) { [weak self] action, view, completion in
                    guard let self = self else {
                        completion(false)
                        return
                    }

                    self.updateRecord(at: indexPath)
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

                    self.presentDeleteRecordAlert(
                        at: indexPath,
                        displaced: true,
                        completion: completion
                    )
                }
                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = .systemRed

                let swipeConfiguration = UISwipeActionsConfiguration(
                    actions: [deleteAction, editAction]
                )
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

        let doorsViewController = DoorsViewController()
        doorsViewController.selectedRecord = record

        let navigationDoorsView = UINavigationController(
            rootViewController: doorsViewController
        )

        if isCompact {
            navigationController?
                .pushViewController(doorsViewController, animated: true)
        } else {
            showDetailViewController(navigationDoorsView, sender: nil)
        }

        selectedIndexPath = indexPath
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let contextMenuConfig = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { actions in
            UIMenu(
                children: [
                    UIAction(
                        title: "Edit",
                        image: UIImage(systemName: "pencil")
                    ) { [weak self] action in
                        self?.updateRecord(at: indexPath)
                    },
                    UIAction(
                        title: "Delete",
                        image: UIImage(systemName: "trash"),
                        attributes: .destructive
                    ) { [weak self] action in
                        self?.presentDeleteRecordAlert(at: indexPath)
                    }
                ]
            )
        }

        return contextMenuConfig
    }
}

extension RecordsViewController {
    private func presentDeleteRecordAlert(
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

        let deleteAction = UIAlertAction(
            title: "Delete",
            style: .destructive
        ) { action in
            self.deleteRecord(at: indexPath)
            completion(true)
        }
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel
        ) { action in
            completion(false)
        }
        alertController.addAction(cancelAction)

        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            alertController.popoverPresentationController?.sourceView = selectedCell
            alertController.popoverPresentationController?.sourceRect = selectedCell
                .bounds
                .offsetBy(
                    dx: displaced ? selectedCell.bounds.width : 0,
                    dy: 0
                )
        }

        present(alertController, animated: true)
    }
}

extension RecordsViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<RecordCell, Record>

    private func configureDataSource() {
        let rowRegistration = CellRegistration {
            [weak self] cell, indexPath, item in

            cell.record = item
            if self?.isCompact ?? false {
                cell.contentInsets = UIEdgeInsets(
                    top: 10,
                    left: 20,
                    bottom: 10,
                    right: 20
                )
            }
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
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]
        if let territory = territory {
            fetchRequest.predicate = NSPredicate(
                format: "territory == %@",
                territory
            )
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
        if let territory = territory {
            fetchRequest.predicate = NSPredicate(
                format: "territory == %@",
                territory
            )
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
