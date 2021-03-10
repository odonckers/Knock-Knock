//
//  SidebarNavigationViewController.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/3/21.
//

import CoreData
import SwiftUI
import UIKit

class SidebarViewController: UIViewController {
    typealias _Object = Territory

    private var sections: [_Section]! = nil

    private var dataSource: _DataSource! = nil
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        return collectionView
    }()

    private var fetchedResultsController: NSFetchedResultsController<Territory>! = nil

    private var adjacentSplitViewColumn: UISplitViewController.Column {
        let isTripleColumn = splitViewController?.style == .tripleColumn
        return isTripleColumn ? .supplementary : .secondary
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("general.home", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false

        setupFetchRequest()

        addNavigationButtons()
        addToolbarButtons()

        loadSidebarItems()

        configureHierarchy()
        configureDataSource()
        applySnapshots()

        setInitialSecondaryView()
    }

    private func addNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.circle"),
            style: .plain,
            target: self,
            action: nil
        )
    }

    private func addToolbarButtons() {
        let addTerritory = UIAction(
            title: "Add Territory",
            image: UIImage(systemName: "folder.badge.plus")
        ) { action in
            
        }

        let addRecord = UIAction(
            title: "Add Record",
            image: UIImage(systemName: "doc.badge.plus")
        ) { action in

        }

        let menu = UIMenu(children: [addTerritory, addRecord])
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(
                image: UIImage(systemName: "plus.circle.fill"),
                menu: menu
            )
        ]
    }
}

extension SidebarViewController: NSFetchedResultsControllerDelegate {
//    func controller(
//        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
//        didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
//    ) {
//        guard let fetchedResultsController = controller as? NSFetchedResultsController<Territory> else {
//            return
//        }
//
//        guard let dataSource = collectionView.dataSource as? _DataSource else {
//            assertionFailure(
//                "The data source has not implemented snapshot support while it should"
//            )
//            return
//        }
//        var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, Territory>
//        let currentSnapshot = dataSource.snapshot() as _Snapshot
//
//        let reloadIdentifiers = snapshot.itemIdentifiers.compactMap { territory in
//            guard let currentIndex = currentSnapshot.indexOfItem(territory.objectID),
//                  let index = snapshot.indexOfItem(itemIdentifier),
//                  index == currentIndex else {
//                return nil
//            }
//            guard let existingObject = try? fetchedResultsController.managedObjectContext.existingObject(
//                with: territory.objectID
//            ),
//            existingObject.isUpdated else {
//                return nil
//            }
//
//            return itemIdentifier
//        } as [_Item]
//        snapshot.reloadItems(reloadIdentifiers)
//
//        let shouldAnimate = collectionView.numberOfSections != 0
//        dataSource.apply(
//            snapshot as _Snapshot,
//            animatingDifferences: shouldAnimate
//        )
//    }
}

// MARK: - Configuration

/// Developer note (Owen Donckers):
///
/// The following extension is the only portion to be changed, with the exception of the `SidebarSection`
/// enumeration. Instead of having a simple array to pull the sections from, having a hard typed enumeration
/// will keep the data type safe.

extension SidebarViewController {
    func loadSidebarItems() {
        sections = [
            _Section(
                isHeaderVisible: false,
                items: [
                    _Item(
                        title: "Records",
                        image: UIImage(systemName: "note.text")
                    )
                ],
                itemSelected: { [weak self] item in
                    guard let self = self else { return }

                    let viewController = UIHostingController(
                        rootView: RecordsView()
                    )
                    self.splitViewController?.setViewController(
                        viewController,
                        for: self.adjacentSplitViewColumn
                    )
                }
            ),
            _Section(
                title: "Territories",
                items: [
                    _Item(
                        title: "Recently Added",
                        image: UIImage(systemName: "clock")
                    ),
                    _Item(
                        title: "Artists",
                        image: UIImage(systemName: "music.mic")
                    ),
                    _Item(
                        title: "Albums",
                        image: UIImage(systemName: "rectangle.stack")
                    ),
                    _Item(
                        title: "Songs",
                        image: UIImage(systemName: "music.note")
                    ),
                    _Item(
                        title: "Music Videos",
                        image: UIImage(systemName: "tv.music.note")
                    ),
                    _Item(
                        title: "TV & Movies",
                        image: UIImage(systemName: "tv")
                    )
                ],
                itemSelected: { [weak self] item in
                    guard let self = self else { return }

                    let viewController = UIHostingController(
                        rootView: RecordsView()
                    )
                    self.splitViewController?.setViewController(
                        viewController,
                        for: self.adjacentSplitViewColumn
                    )
                },
                itemMenuConfig: { item -> UIContextMenuConfiguration? in
                    UIContextMenuConfiguration(
                        identifier: nil,
                        previewProvider: nil
                    ) { suggestedActions in
                        let actions = [
                            UIAction(
                                title: "Edit",
                                image: UIImage(systemName: "pencil")
                            ) { action in
                                print("Hello, World!")
                            },
                            UIAction(
                                title: "Delete \(item.title)",
                                image: UIImage(systemName: "trash"),
                                attributes: .destructive
                            ) { action in
                                print("Hello, World!")
                            }
                        ]

                        return UIMenu(
                            title: "Open",
                            options: .displayInline,
                            children: actions
                        )
                    }
                },
                itemTrailingSwipeAction: {
                    item -> UISwipeActionsConfiguration? in

                    let editHandler: UIContextualAction.Handler = { [weak self] action, view, completion in
                        guard let self = self else {
                            completion(false)
                            return
                        }

                        var snapshot = self.dataSource.snapshot()
                        item.title = "Random"

                        snapshot.reloadItems([item])
                        self.dataSource.apply(
                            snapshot,
                            animatingDifferences: true
                        )

                        completion(true)
                    }

                    let deleteHandler: UIContextualAction.Handler = { [weak self] action, view, completion in
                        guard let self = self else {
                            completion(false)
                            return
                        }

                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteItems([item])
                        self.dataSource.apply(
                            snapshot,
                            animatingDifferences: true
                        )

                        completion(true)
                    }

                    let editAction = UIContextualAction(
                        style: .normal,
                        title: "Edit",
                        handler: editHandler
                    )
                    editAction.image = UIImage(systemName: "pencil")
                    editAction.backgroundColor = .systemBlue

                    let deleteAction = UIContextualAction(
                        style: .destructive,
                        title: "Delete",
                        handler: deleteHandler
                    )
                    deleteAction.image = UIImage(systemName: "trash.fill")
                    deleteAction.backgroundColor = .systemRed

                    let configuration = UISwipeActionsConfiguration(
                        actions: [deleteAction, editAction]
                    )
                    configuration.performsFirstActionWithFullSwipe = false

                    return configuration
                }
            )
        ]
    }
}

// MARK: - Layout

private extension SidebarViewController {
    func configureHierarchy() {
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard let self = self else { return nil }
            let section = self.sections[sectionIndex]

            var config = UICollectionLayoutListConfiguration(
                appearance: .sidebar
            )
            config.headerMode = section.isHeaderVisible ?
                .firstItemInSection :
                .none

            config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else { return nil }
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                if item.isHeader { return nil }

                return section.itemLeadingSwipeAction(item)
            }
            config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else { return nil }
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else {
                    return nil
                }
                if item.isHeader { return nil }

                return section.itemTrailingSwipeAction(item)
            }

            return NSCollectionLayoutSection.list(
                using: config,
                layoutEnvironment: layoutEnvironment
            )
        }
    }

    func setInitialSecondaryView() {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(
            at: indexPath,
            animated: false,
            scrollPosition: .centeredVertically
        )

        let section = sections[indexPath.section]
        if let item = dataSource.itemIdentifier(for: indexPath) {
            section.itemSelected(item)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SidebarViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let section = sections[indexPath.section]
        if let item = dataSource.itemIdentifier(for: indexPath),
           !item.isHeader {
            section.itemSelected(item)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        if item.isHeader { return nil }

        let section = sections[indexPath.section]
        return section.itemMenuConfig(item)
    }
}

// MARK: - Data

private extension SidebarViewController {
    func setupFetchRequest() {
        let fetchRequest = NSFetchRequest<Territory>()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let context = PersistenceController.shared.container.viewContext
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
    }

    func configureDataSource() {
        let headerRegistration = _CellRegistration { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()]
        }

        let cellRegistration = _CellRegistration { cell, indexPath, item in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
            cell.accessories = []
        }

        dataSource = _DataSource(collectionView: collectionView) { (
            collectionView: UICollectionView,
            indexPath: IndexPath,
            item: _Item
        ) -> UICollectionViewCell? in
            if item.isHeader {
                return collectionView.dequeueConfiguredReusableCell(
                    using: headerRegistration,
                    for: indexPath,
                    item: item
                )
            }

            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }

    func applySnapshots() {
        let sections = self.sections ?? []
        var snapshot = _Snapshot()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: true)

        for section in sections {
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<_Item>()

            if section.isHeaderVisible {
                let headerItem = _Item(
                    isHeader: true,
                    title: section.title ?? "Unknown"
                )
                sectionSnapshot.append([headerItem])
                sectionSnapshot.append(section.items, to: headerItem)
                sectionSnapshot.expand([headerItem])
            } else {
                sectionSnapshot.append(section.items)
            }

            dataSource.apply(sectionSnapshot, to: section)
        }
    }
}

// MARK: - Type Aliases

private extension SidebarViewController {
    typealias _Section = SidebarSection<_Object>
    typealias _Item = SidebarItem<_Object>

    typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, _Item>
    typealias _DataSource = UICollectionViewDiffableDataSource<_Section, _Item>

    typealias _CellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, _Item>
}

// MARK: - Enums, classes, etc.

struct SidebarSection<Object: NSManagedObject>: Hashable {
    private var identifier = UUID()

    var title: String?
    var isHeaderVisible: Bool

    var items: [Item]

    var itemSelected: (Item) -> Void
    var itemMenuConfig: (Item) -> UIContextMenuConfiguration?
    var itemLeadingSwipeAction: (Item) -> UISwipeActionsConfiguration?
    var itemTrailingSwipeAction: (Item) -> UISwipeActionsConfiguration?

    init(
        title: String? = nil,
        isHeaderVisible: Bool = true,
        items: [Item],
        itemSelected: @escaping (Item) -> Void = { _ in },
        itemMenuConfig: @escaping (Item) -> UIContextMenuConfiguration? = { _ in nil },
        itemLeadingSwipeAction: @escaping (Item) -> UISwipeActionsConfiguration? = { _ in nil },
        itemTrailingSwipeAction: @escaping (Item) -> UISwipeActionsConfiguration? = { _ in nil }
    ) {
        self.title = title
        self.isHeaderVisible = isHeaderVisible

        self.items = items

        self.itemSelected = itemSelected
        self.itemMenuConfig = itemMenuConfig
        self.itemLeadingSwipeAction = itemLeadingSwipeAction
        self.itemTrailingSwipeAction = itemTrailingSwipeAction
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

extension SidebarSection {
    typealias Item = SidebarItem<Object>
}

class SidebarItem<Object: NSManagedObject>: Hashable {
    private var identifier = UUID()

    fileprivate var isHeader = false

    var title: String
    var image: UIImage? = nil
    var object: Object? = nil

    init(
        isHeader: Bool = false,
        title: String,
        image: UIImage? = nil,
        object: Object? = nil
    ) {
        self.isHeader = isHeader
        self.title = title
        self.image = image
        self.object = object
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: SidebarItem, rhs: SidebarItem) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
