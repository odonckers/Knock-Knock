//
//  RecordsCollectionView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import UIKit

extension RecordsViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<
        SidebarSection,
        SidebarItem
    >
    typealias Snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>

    func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: makeLayout()
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        return collectionView
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: {
                [weak self] (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

                guard let self = self else { return nil }

                var configuration = UICollectionLayoutListConfiguration(
                    appearance: self.isCompact ? .insetGrouped : .sidebar
                )
                configuration.showsSeparators = self.isCompact
                configuration.headerMode = sectionIndex == 0 ? .none : .firstItemInSection
                configuration.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                    guard let item = self?.dataSource.itemIdentifier(for: indexPath)
                    else { return nil }

                    switch item.object {
                    case is Territory:
                        return self?.territoryLeadingSwipeActions(item.object as! Territory)
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
        )
        return layout
    }

    func makeDataSource() -> DataSource {
        let headerRegistration = headerRegistration()
        let expandableRowRegistration = expandableRowRegistration()
        let rowRegistration = rowRegistration()

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
        )
    }

    func recordsSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        let items = viewModel.fetchedRecordsList.objects.map { record in recordRow(record: record) }

        snapshot.append(items)
        return snapshot
    }

    func territoriesSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        let header: SidebarItem = .header(title: "Territories")
        snapshot.append([header])
        snapshot.expand([header])

        viewModel.fetchedTerritoriesList.objects.forEach { territory in
            let expandableRow: SidebarItem = .expandableRow(
                image: UIImage(systemName: "folder"),
                title: territory.wrappedName,
                subtitle: nil,
                id: territory.wrappedID,
                object: territory
            )

            let items: [SidebarItem] = territory.recordArray.map { record in
                recordRow(record: record)
            }

            snapshot.append([expandableRow], to: header)
            snapshot.expand([expandableRow])
            snapshot.append(items, to: expandableRow)
        }

        return snapshot
    }
}

extension RecordsViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }

        if item.type == .header { return false }

        switch item.object {
        case is Territory: return false
        default: return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item.object {
        case is Record: didSelectRecord(item.object as! Record)
        default: break
        }

        selectedCollectionCell = indexPath
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

    private func didSelectRecord(_ record: Record) {
        let doorsViewController = DoorsViewController(in: record)
        let navigationController = UINavigationController(rootViewController: doorsViewController)

        showDetailViewController(navigationController, sender: nil)
        view.window?.windowScene?.title = record.wrappedStreetName
    }
}
