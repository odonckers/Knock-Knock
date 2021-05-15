//
//  RecordsCells.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import UIKit

extension RecordsViewController {
    typealias CellRegistration = UICollectionView.CellRegistration<
        UICollectionViewListCell,
        SidebarItem
    >

    func headerRegistration() -> CellRegistration {
        CellRegistration { [weak self] cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title

            if let self = self, self.isCompact {
                contentConfiguration.textProperties.color = .label
                contentConfiguration.textProperties.transform = .none
                contentConfiguration.textProperties.font = UIFont
                    .preferredFont(forTextStyle: .title3)
                    .withTraits(.traitBold)
            }

            cell.contentConfiguration = contentConfiguration
            cell.tintColor = item.tintColor

            var accessories = [UICellAccessory]()
            if item.hasExpander {
                let headerDiscosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
                accessories.append(.outlineDisclosure(options: headerDiscosureOption))
            }

            cell.accessories = accessories
        }
    }

    func expandableRowRegistration() -> CellRegistration {
        CellRegistration { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            cell.contentConfiguration = contentConfiguration
            cell.tintColor = item.tintColor

            var accessories = [UICellAccessory]()
            if item.hasExpander {
                let headerDiscosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
                accessories.append(.outlineDisclosure(options: headerDiscosureOption))
            }

            cell.accessories = accessories
        }
    }

    func rowRegistration() -> CellRegistration {
        CellRegistration { [weak self] cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = item.title
            contentConfiguration.secondaryText = item.subtitle
            contentConfiguration.image = item.image

            contentConfiguration.textProperties.font = UIFont
                .preferredFont(forTextStyle: .subheadline)
                .withTraits(.traitBold)

            cell.contentConfiguration = contentConfiguration
            cell.tintColor = item.tintColor

            var accessories = [UICellAccessory]()
            if item.hasChild && self?.isCompact ?? false {
                accessories.append(.disclosureIndicator())
            }

            cell.accessories = accessories
        }
    }
}

extension RecordsViewController {
    func recordRow(record: Record) -> SidebarItem {
        var title = [String]()
        if let apartmentNumber = record.apartmentNumber { title.append(apartmentNumber) }
        title.append(record.wrappedStreetName)

        var subtitle = [String]()
        if let city = record.city, city != "" { subtitle.append(city) }
        if let state = record.state, state != "" { subtitle.append(state) }

        return .row(
            image: UIImage(
                systemName: record.wrappedType == .apartment ? "a.square.fill" : "s.square.fill"
            ),
            title: title.joined(separator: " "),
            subtitle: subtitle.count > 0 ? subtitle.joined(separator: ", ") : nil,
            tintColor: UIColor(
                record.wrappedType == .apartment ? .recordTypeApartment : .recordTypeStreet
            ),
            hasChild: true,
            id: record.wrappedID,
            object: record
        )
    }
}

extension RecordsViewController {
    func recordTrailingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit",
            handler: { [weak self] action, view, completion in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(for: indexPath),
                    let record = sidebarItem.object as? Record
                else {
                    completion(false)
                    return
                }

                self.presentRecordFormView(record: record)
                completion(true)
            }
        )
        editAction.image = UIImage(
            systemName: "pencil.circle.fill",
            withConfiguration: largeSymbolConfig
        )
        editAction.backgroundColor = .systemGray3

        let moveAction = UIContextualAction(
            style: .normal,
            title: "Move",
            handler: { [weak self] action, view, completion in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(for: indexPath),
                    let record = sidebarItem.object as? Record
                else {
                    completion(false)
                    return
                }

                self.presentMoveRecordView(record: record)
                completion(true)
            }
        )
        moveAction.image = UIImage(
            systemName: "folder.circle.fill",
            withConfiguration: largeSymbolConfig
        )
        moveAction.backgroundColor = .systemIndigo

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { [weak self] action, view, completion in
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
        )
        deleteAction.image = UIImage(
            systemName: "trash.circle.fill",
            withConfiguration: largeSymbolConfig
        )
        deleteAction.backgroundColor = .systemRed

        let swipeConfiguration = UISwipeActionsConfiguration(
            actions: [deleteAction, moveAction, editAction]
        )
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }

    func recordContextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration {
        let editAction = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil"),
            handler: { [weak self] action in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(
                        for: indexPath
                    ),
                    let record = sidebarItem.object as? Record
                else { return }

                self.presentRecordFormView(record: record)
            }
        )

        let moveAction = UIAction(
            title: "Move",
            image: UIImage(systemName: "folder"),
            handler: { [weak self] action in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(
                        for: indexPath
                    ),
                    let record = sidebarItem.object as? Record
                else { return }

                self.presentMoveRecordView(record: record)
            }
        )

        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] action in
                self?.verifyRecordDeletion(at: indexPath)
            }
        )

        let contextMenuConfig = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { actions in
                UIMenu(
                    children: [
                        UIMenu(
                            title: "Edit...",
                            options: .displayInline,
                            children: [editAction, moveAction]
                        ),
                        deleteAction
                    ]
                )
            }
        )
        return contextMenuConfig
    }

    func verifyRecordDeletion(
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
            style: .destructive,
            handler: { [weak self] action in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(for: indexPath),
                    let record = sidebarItem.object as? Record
                else { return }

                self.viewModel.deleteRecord(record)
                completion(true)
            }
        )
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { action in
                completion(false)
            }
        )
        alertController.addAction(cancelAction)

        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            alertController.popoverPresentationController?.sourceView = selectedCell
            alertController.popoverPresentationController?.sourceRect = selectedCell
                .bounds
                .offsetBy(dx: displaced ? selectedCell.bounds.width : 0, dy: 0)
        }

        present(alertController, animated: true)
    }

    func presentMoveRecordView(record: Record) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet
        navigationController.isModalInPresentation = true

        MoveRecordView(record: record)
            .environment(\.managedObjectContext, viewModel.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }

    func presentRecordFormView(record: Record? = nil) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet
        navigationController.isModalInPresentation = true

        RecordFormView(record: record, territory: record?.territory)
            .environment(\.managedObjectContext, viewModel.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }

    func presentRecordFormView(territory: Territory) {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .formSheet
        navigationController.isModalInPresentation = true

        RecordFormView(territory: territory)
            .environment(\.managedObjectContext, viewModel.moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        present(navigationController, animated: true)
    }
}

extension RecordsViewController {
    func territoryLeadingSwipeActions(_ territory: Territory) -> UISwipeActionsConfiguration {
        let addAction = UIContextualAction(
            style: .normal,
            title: "Add Record",
            handler: { [weak self] action, view, completion in
                guard let self = self else {
                    completion(false)
                    return
                }

                self.presentRecordFormView(territory: territory)

                completion(true)
            }
        )
        addAction.image = UIImage(
            systemName: "note.text.badge.plus",
            withConfiguration: largeSymbolConfig
        )
        addAction.backgroundColor = .accentColor

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [addAction])
        return swipeConfiguration
    }

    func territoryTrailingSwipeActions(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit",
            handler: { [weak self] action, view, completion in
                guard let self = self else {
                    completion(false)
                    return
                }

                self.presentTerritoryForm(from: indexPath)
                completion(true)
            }
        )
        editAction.image = UIImage(
            systemName: "pencil.circle.fill",
            withConfiguration: largeSymbolConfig
        )
        editAction.backgroundColor = .systemGray3

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete",
            handler: { [weak self] action, view, completion in
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
        )
        deleteAction.image = UIImage(
            systemName: "trash.circle.fill",
            withConfiguration: largeSymbolConfig
        )
        deleteAction.backgroundColor = .systemRed

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }

    func territoryContextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration {
        let addRecordAction = UIAction(
            title: "Add Record",
            image: UIImage(systemName: "plus"),
            handler: { [weak self] action in
                guard
                    let self = self,
                    let item = self.dataSource.itemIdentifier(for: indexPath),
                    let territory = item.object as? Territory
                else { return }

                self.presentRecordFormView(territory: territory)
            }
        )

        let editAction = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil"),
            handler: { [weak self] action in
                self?.presentTerritoryForm(from: indexPath)
            }
        )

        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive,
            handler: { [weak self] action in
                self?.verifyTerritoryDeletion(at: indexPath)
            }
        )

        let contextMenuConfig = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { actions in
                UIMenu(
                    children: [
                        addRecordAction,
                        UIMenu(
                            title: "Edit...",
                            options: .displayInline,
                            children: [editAction, deleteAction]
                        ),
                    ]
                )
            }
        )
        return contextMenuConfig
    }

    func verifyTerritoryDeletion(
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
            style: .destructive,
            handler: { [weak self] action in
                guard
                    let self = self,
                    let sidebarItem = self.dataSource.itemIdentifier(for: indexPath),
                    let territory = sidebarItem.object as? Territory
                else { return }

                self.viewModel.deleteTerritory(territory)
                completion(true)
            }
        )
        alertController.addAction(deleteAction)

        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { action in
                completion(false)
            }
        )
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
