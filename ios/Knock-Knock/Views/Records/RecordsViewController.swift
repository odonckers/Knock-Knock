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

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Record>!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = territory != nil ? territory!.wrappedName : "Records"

        if let navigationController = navigationController {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.tabBarItem.image = UIImage(
                systemName: "note.text"
            )
            navigationController.tabBarItem.title = "Records"
        }

        configureCollectionView()
        configureDataSource()
        applySnapshot()
        configureFetchRequests()
    }

    func setTerritory(_ territory: Territory? = nil) {
        self.territory = territory
        title = territory != nil ? territory!.wrappedName : "Records"

        configureFetchRequests()
        applySnapshot()
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
    private func configureDataSource() {
        let rowRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Record> {
            cell, indexPath, item in

            var contentConfiguration: UIListContentConfiguration = .accompaniedSidebarSubtitleCell()
            contentConfiguration.text = item.wrappedStreetName
            contentConfiguration.textProperties.font = .systemFont(ofSize: 18)

            var secondaryTexts: [String] = []
            if let city = item.city {
                secondaryTexts.append(city)
            }
            if let state = item.state {
                secondaryTexts.append(state)
            }
            contentConfiguration.secondaryText = secondaryTexts.joined(
                separator: ", "
            )

            cell.contentConfiguration = contentConfiguration
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Record>(
            collectionView: collectionView
        ) { (collectionView, indexPath, item) -> UICollectionViewCell in
            return collectionView.dequeueConfiguredReusableCell(
                using: rowRegistration,
                for: indexPath,
                item: item
            )
        }
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
