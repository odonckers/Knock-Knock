//
//  TerritoriesViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import CoreData
import UIKit

class TerritoriesViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Territory>!

    private var moc: NSManagedObjectContext!
    private var fetchedTerritoriesController: NSFetchedResultsController<Territory>!

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

extension TerritoriesViewController {
    private func configureNavigationBar() {
        title = TabBarItem.territories.title
        navigationController?.navigationBar.prefersLargeTitles = true

        let addTerritoryButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            primaryAction: UIAction { [weak self] action in
                self?.presentTerritoryForm()
            }
        )
        navigationItem.rightBarButtonItem = addTerritoryButton
    }
}

extension TerritoriesViewController {
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
                appearance: .plain
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

                    self.presentDeleteTerritoryAlert(
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

extension TerritoriesViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let territory = dataSource.itemIdentifier(for: indexPath)
        else { return }

        let recordsViewController = RecordsViewController(
            territory: territory,
            isCompact: true
        )

        navigationController?
            .pushViewController(recordsViewController, animated: true)

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
                        self?.presentTerritoryForm(itemAt: indexPath)
                    },
                    UIAction(
                        title: "Delete",
                        image: UIImage(systemName: "trash"),
                        attributes: .destructive
                    ) { [weak self] action in
                        self?.presentDeleteTerritoryAlert(at: indexPath)
                    }
                ]
            )
        }

        return contextMenuConfig
    }
}

extension TerritoriesViewController {
    private func presentDeleteTerritoryAlert(
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
            self.deleteTerritory(at: indexPath)
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

extension TerritoriesViewController {
    private typealias CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Territory>

    private func configureDataSource() {
        let rowRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.wrappedName

            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Territory>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(
                using: rowRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    private func territoriesSnapshot() -> NSDiffableDataSourceSectionSnapshot<Territory> {
        var snapshot = NSDiffableDataSourceSectionSnapshot<Territory>()

        var items = [Territory]()
        if let records = fetchedTerritoriesController.fetchedObjects {
            items = records
        }

        snapshot.append(items)
        return snapshot
    }

    private func applyInitialSnapshot() {
        dataSource.apply(territoriesSnapshot(), to: 0, animatingDifferences: false)
    }

    private func updateSnapshot() {
        let snapshot = territoriesSnapshot()
        dataSource.apply(snapshot, to: 0, animatingDifferences: true)
    }
}

extension TerritoriesViewController {
    private func configureViewContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistenceController.container.viewContext
    }

    private func configureFetchRequests() {
        let fetchRequest: NSFetchRequest<Territory> = Territory.fetchRequest()
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
            applyInitialSnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }

    private func refreshFetchRequests() {
        do {
            try fetchedTerritoriesController.performFetch()
            applyInitialSnapshot()
        } catch {
            // Failed to fetch results from the database. Handle errors appropriately in your app.
        }
    }
}

extension TerritoriesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        updateSnapshot()
    }
}

extension TerritoriesViewController {
    private func presentTerritoryForm(itemAt indexPath: IndexPath) {
        guard let territory = dataSource.itemIdentifier(for: indexPath)
        else { return }

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
            [unowned alertController] action in

            guard let textFields = alertController.textFields
            else { return }

            let nameField = textFields[0]

            var toSave: Territory
            if let territory = territory {
                toSave = territory
                toSave.willUpdate()
            } else {
                toSave = Territory(context: self.moc)
                toSave.willCreate()
            }

            toSave.name = nameField.text
            self.moc.unsafeSave()
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
        guard let territory = dataSource.itemIdentifier(for: indexPath)
        else { return }

        deleteTerritory(territory)
    }

    private func deleteTerritory(_ territory: Territory) {
        moc.delete(territory)
        moc.unsafeSave()
    }
}
