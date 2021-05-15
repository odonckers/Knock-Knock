//
//  DoorsViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/26/21.
//

import Combine
import CoreData
import UIKit

class DoorsViewController: UIViewController {
    let record: Record

    var moc: NSManagedObjectContext
    let viewModel: DoorsViewModel

    init(in record: Record) {
        self.record = record

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        moc = appDelegate.persistenceController.container.viewContext
        viewModel = DoorsViewModel(moc: moc, record: record)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cancellables = Set<AnyCancellable>()

    private lazy var addDoorBarButtonItem = makeAddDoorBarButton()

    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.apply(doorsSnapshot(), animatingDifferences: false)
        viewModel.fetchedDoorsList.contentDidChange
            .sink { [weak self] in
                guard let self = self else { return }

                let snapshot = self.doorsSnapshot()
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        var title = [record.wrappedStreetName]
        if let apartmentNumber = record.apartmentNumber { title.insert(apartmentNumber, at: 0) }

        self.title = title.joined(separator: " ")
        navigationItem.largeTitleDisplayMode = .never

        toolbarItems = [.flexibleSpace(), addDoorBarButtonItem]
        navigationController?.isToolbarHidden = false

        view.addSubview(collectionView)
    }
}

// MARK: - Top Bar

extension DoorsViewController {
    private func makeAddDoorBarButton() -> UIBarButtonItem {
        UIBarButtonItem(
            title: "Add Door",
            image: UIImage(systemName: "plus.circle"),
            primaryAction: UIAction { [weak self] action in
                guard let self = self else { return }

                let navigationController = UINavigationController()
                navigationController.modalPresentationStyle = .formSheet

                DoorFormView(record: self.record)
                    .environment(\.managedObjectContext, self.moc)
                    .environment(\.uiNavigationController, navigationController)
                    .assignToUI(navigationController: navigationController)

                self.present(navigationController, animated: true)
            }
        )
    }
}

// MARK: - Collection Layout

extension DoorsViewController {
    private func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: makeLayout()
        )
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        return collectionView
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
                configuration.showsSeparators = true
                configuration.headerMode = .firstItemInSection

                let section: NSCollectionLayoutSection = .list(
                    using: configuration,
                    layoutEnvironment: layoutEnvironment
                )
                return section
            }
        )
        return layout
    }
}

// MARK: - Collection Delegate

extension DoorsViewController: UICollectionViewDelegate { }

// MARK: - Data Source & Snapshots

extension DoorsViewController {
    private typealias HeaderRegistration = UICollectionView.CellRegistration<
        CollectionListHeaderCell,
        CollectionItem
    >

    private typealias CellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell,
        CollectionItem
    >

    private typealias DataSource = UICollectionViewDiffableDataSource<
        VisitSymbol,
        CollectionItem
    >

    private func makeDataSource() -> DataSource {
        let headerRegistration = HeaderRegistration { cell, indexPath, item in
            var contentConfiguration = CollectionListHeaderCellContentConfiguration()
            contentConfiguration.systemImage = item.systemImage
            contentConfiguration.title = item.title
            contentConfiguration.foregroundColor = item.foregroundColor

            cell.contentConfiguration = contentConfiguration
            cell.backgroundColor = .systemBackground
        }

        let rowRegistration = CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            if let systemImage = item.systemImage {
                contentConfiguration.image = UIImage(systemName: systemImage)
            }

            cell.contentConfiguration = contentConfiguration
            cell.tintColor = item.foregroundColor

            var accessories = [UICellAccessory]()
            if item.hasChild { accessories.append(.disclosureIndicator()) }

            cell.accessories = accessories
        }

        return DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                switch item.type {
                case .header:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: headerRegistration,
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
        )
    }

    private func doorsSnapshot() -> NSDiffableDataSourceSnapshot<VisitSymbol, CollectionItem> {
        var snapshot = NSDiffableDataSourceSnapshot<VisitSymbol, CollectionItem>()

        viewModel.fetchedDoorsList.sections.forEach { section in
            if
                let sectionInt = Int16(section.name),
                let visitSymbol = VisitSymbol(rawValue: sectionInt),
                let doors = section.objects as? [Door]
            {
                var items: [CollectionItem] = [
                    .header(
                        systemImage: visitSymbol.systemImage,
                        title: visitSymbol.text,
                        foregroundColor: UIColor(visitSymbol.color)
                    )
                ]
                doors.forEach { door in items.append(doorRow(door)) }

                snapshot.appendSections([visitSymbol])
                snapshot.appendItems(items, toSection: visitSymbol)
            }
        }

        return snapshot
    }

    private func doorRow(_ door: Door) -> CollectionItem {
        var symbolColor: UIColor? = nil
        if let latestVisit = door.latestVisit {
            symbolColor = UIColor(latestVisit.symbolColor)
        }

        return .row(
            title: door.wrappedNumber,
            foregroundColor: symbolColor,
            hasChild: false,
            id: door.wrappedID,
            object: door
        )
    }
}

// MARK: - Enums, Structs, etc.

extension DoorsViewController {
    private struct CollectionSection: Hashable, Identifiable {
        let id: String
        let title: String
    }

    private enum CollectionItemType: Int {
        case header, row
    }

    private struct CollectionItem: Hashable, Identifiable {
        let id: String
        private(set) var object: NSManagedObject?
        private(set) var type: CollectionItemType
        private(set) var systemImage: String? = nil
        private(set) var title: String? = nil
        private(set) var subtitle: String? = nil
        private(set) var foregroundColor: UIColor? = nil
        private(set) var hasChild: Bool = false

        static func header(
            systemImage: String? = nil,
            title: String,
            foregroundColor: UIColor = .label,
            id: String = UUID().uuidString
        ) -> Self {
            CollectionItem(
                id: id,
                type: .header,
                systemImage: systemImage,
                title: title,
                foregroundColor: foregroundColor
            )
        }

        static func row(
            systemImage: String? = nil,
            title: String,
            subtitle: String? = nil,
            foregroundColor: UIColor? = nil,
            hasChild: Bool = false,
            id: String = UUID().uuidString,
            object: NSManagedObject? = nil
        ) -> Self {
            CollectionItem(
                id: id,
                object: object,
                type: .row,
                systemImage: systemImage,
                title: title,
                subtitle: subtitle,
                foregroundColor: foregroundColor,
                hasChild: hasChild
            )
        }
    }
}
