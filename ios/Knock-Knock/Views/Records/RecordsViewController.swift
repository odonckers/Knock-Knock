//
//  RecordsViewController.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/23/21.
//

import CoreData
import SwiftUI
import UIKit

class RecordsViewController: UIViewController {
    var selectedTerritory: Territory? {
        get { territory }
        set(newValue) {
            territory = newValue
            title = newValue != nil ? newValue!.wrappedName : "Records"
            refreshFetchRequests()
        }
    }
    private var territory: Territory?

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Record>!

    private var persistenceController: PersistenceController!
    private var fetchedRecordsController: NSFetchedResultsController<Record>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()

        configureCollectionView()

        configureDataSource()

        configurePersistenceController()
        configureFetchRequests()
    }
}

extension RecordsViewController {
    private func configureNavigationBar() {
        title = territory != nil ? territory!.wrappedName : "Records"
        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.tabBarItem.image = UIImage(
                systemName: "note.text"
            )
            navigationController.tabBarItem.title = "Records"
        }

        let addRecordButton = UIBarButtonItem(
            title: "Add Record",
            image: UIImage(systemName: "plus.circle.fill"),
            primaryAction: UIAction { [weak self] action in
                guard let self = self else { return }

                let recordForm = HostingController(
                    rootView: RecordFormView(territory: self.territory)
                )
                recordForm.modalPresentationStyle = .formSheet
                self.present(recordForm, animated: true)
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
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(
                appearance: .sidebarPlain
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

                    let confirmAction = UIAlertAction(
                        title: "Confirm",
                        style: .default,
                        handler: { action in
                            self.deleteRecord(at: indexPath)
                            completion(true)
                        }
                    )
                    let cancelAction = UIAlertAction(
                        title: "Cancel",
                        style: .cancel,
                        handler: { _ in completion(false) }
                    )

                    let alert = UIAlertController(
                        title: "Are you sure?",
                        message: "This action will permanently delete it.",
                        preferredStyle: .alert
                    )
                    alert.addAction(confirmAction)
                    alert.addAction(cancelAction)

                    self.present(alert, animated: true)
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

        let doorsView = DoorsView(record: record)
        let hostedDoorsView = UIHostingController(rootView: doorsView)

        showDetailViewController(hostedDoorsView, sender: nil)
    }
}

extension RecordsViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<RecordCell, Record>

    private func configureDataSource() {
        let rowRegistration = CellRegistration { cell, indexPath, item in
            cell.record = item
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Record>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                collectionView.dequeueConfiguredReusableCell(
                    using: rowRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
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
        dataSource.apply(
            recordsSnapshot(),
            to: 0,
            animatingDifferences: false
        )
    }

    private func updateSnapshot() {
        let snapshot = recordsSnapshot()
        dataSource.apply(snapshot, to: 0, animatingDifferences: true)
    }
}

extension RecordsViewController {
    private func configurePersistenceController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        persistenceController = appDelegate.persistenceController
    }

    private func configureFetchRequests() {
        let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]

        fetchedRecordsController = NSFetchedResultsController<Record>(
            fetchRequest: fetchRequest,
            managedObjectContext: persistenceController.container.viewContext,
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
        persistenceController.container.viewContext.delete(
            record
        )
        persistenceController.container.viewContext.unsafeSave()
    }

    private func updateRecord(at indexPath: IndexPath) {
        guard let record = dataSource.itemIdentifier(for: indexPath)
        else { return }
        updateRecord(record)
    }

    private func updateRecord(_ record: Record) {
        let recordForm = HostingController(
            rootView: RecordFormView(
                record: record,
                territory: territory
            )
        )
        recordForm.modalPresentationStyle = .formSheet
        present(recordForm, animated: true)
    }
}
