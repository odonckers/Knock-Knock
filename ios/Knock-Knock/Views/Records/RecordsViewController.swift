//
//  RecordsViewController.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/23/21.
//

import CoreData
import UIKit

class RecordsViewController: UIViewController {
    var selectedTerritory: Territory? {
        get { territory }
        set(newValue) {
            territory = newValue

            title = newValue != nil ? newValue!.wrappedName : "Records"

            configureFetchRequests()
            applySnapshot()
        }
    }
    private var territory: Territory?

    private lazy var persistenceController: PersistenceController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistenceController
    }()
    private lazy var fetchedRecordsController: NSFetchedResultsController<Record> = {
        var fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]

        let fetchedRecordsController = NSFetchedResultsController<Record>(
            fetchRequest: fetchRequest,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedRecordsController.delegate = self
        return fetchedRecordsController
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        return collectionView
    }()
    private var dataSource: UICollectionViewDiffableDataSource<Int, Record>!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)

        setupNavigationBar()

        configureDataSource()
        applySnapshot()
        configureFetchRequests()
    }
}

extension RecordsViewController {
    func setTerritory(_ territory: Territory? = nil) {
        self.territory = territory
        title = territory != nil ? territory!.wrappedName : "Records"

        configureFetchRequests()
        applySnapshot()
    }
}

extension RecordsViewController {
    private func setupNavigationBar() {
        title = territory != nil ? territory!.wrappedName : "Records"
        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.tabBarItem.image = UIImage(
                systemName: "note.text"
            )
            navigationController.tabBarItem.title = "Records"
        }
    }
}

extension RecordsViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout() {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            var configuration = UICollectionLayoutListConfiguration(
                appearance: .sidebarPlain
            )
            configuration.showsSeparators = true
            configuration.headerMode = .none

            configuration.trailingSwipeActionsConfigurationProvider = {
                [weak self] indexPath in

                guard let self = self else { return nil }

                let editAction = UIContextualAction(
                    style: .normal,
                    title: "Edit"
                ) { action, view, completion in
                    completion(true)
                }
                editAction.image = UIImage(systemName: "pencil")
                editAction.backgroundColor = .systemBlue

                let deleteAction = UIContextualAction(
                    style: .destructive,
                    title: "Delete"
                ) { [weak self] action, view, completion in
                    guard let self = self else { return }

                    let defaultAction = UIAlertAction(
                        title: "Confirm",
                        style: .default
                    ) { action in
                    }
                    let cancelAction = UIAlertAction(
                        title: "Cancel",
                        style: .cancel
                    ) { action in
                    }

                    // Create and configure the alert controller.
                    let alert = UIAlertController(
                        title: "Are you sure?",
                        message: "This action will permanently delete it.",
                        preferredStyle: .alert
                    )
                    alert.addAction(defaultAction)
                    alert.addAction(cancelAction)

                    self.present(alert, animated: true) {
                       // The alert was presented
                    }

                    completion(true)
                }
                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = .systemRed

                return UISwipeActionsConfiguration(
                    actions: [deleteAction, editAction]
                )
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

extension RecordsViewController: UICollectionViewDelegate {}

extension RecordsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        applySnapshot()
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

    private func configureFetchRequests() {
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
            applySnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
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

    private func applySnapshot() {
        let snapshot = recordsSnapshot()
        dataSource.apply(snapshot, to: 0, animatingDifferences: false)
    }
}
