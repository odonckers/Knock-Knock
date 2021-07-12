//
//  RecordsViewModel.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import Combine
import CoreData
import Foundation
import UIKit

class RecordsViewModel: ObservableObject {
    typealias Snapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>

    let moc: NSManagedObjectContext

    init(moc: NSManagedObjectContext = .view) {
        self.moc = moc

        $recordsSnapshot.applyingChanges(recordChanges) { record in self.recordRow(record: record) }
            .assign(to: \.recordsSnapshot, on: self)
            .store(in: &cancellables)

        let header: SidebarItem = .header(title: "Territories")
        territoriesSnapshot.append([header])
        territoriesSnapshot.expand([header])

        $territoriesSnapshot.applyingChanges(territoryChanges) { territory in
            .expandableRow(
                image: UIImage(systemName: "folder"),
                title: territory.wrappedName,
                subtitle: nil,
                id: territory.wrappedID,
                object: territory
            )
        } onInsert: { territory, sidebarItem, snapshot in
            snapshot.append([sidebarItem], to: header)
            snapshot.expand([sidebarItem])

            let items: [SidebarItem] = territory.recordArray.map { record in
                self.recordRow(record: record)
            }
            snapshot.append(items, to: sidebarItem)
        }
        .assign(to: \.territoriesSnapshot, on: self)
        .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var recordsSnapshot = Snapshot()
    @ManagedObjectChanges(
        fetchRequest: Record.fetchRequest(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Record.streetName, ascending: true)],
        predicate: NSPredicate(format: "territory == NULL")
    )
    private var recordChanges

    @Published private(set) var territoriesSnapshot = Snapshot()
    @ManagedObjectChanges(
        fetchRequest: Territory.fetchRequest(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Territory.name, ascending: true)]
    )
    private var territoryChanges

    private func recordRow(record: Record) -> SidebarItem {
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

    func deleteRecord(_ record: Record) {
        moc.delete(record)
        moc.unsafeSave()
    }

    func addTerritory(named name: String?) {
        let toSave = Territory(context: self.moc)
        toSave.willCreate()
        toSave.name = name
        self.moc.unsafeSave()
    }

    func updateTerritory(territory: Territory, to name: String?) {
        territory.willUpdate()
        territory.name = name
        moc.unsafeSave()
    }

    func deleteTerritory(_ territory: Territory) {
        moc.delete(territory)
        moc.unsafeSave()
    }
}

enum SidebarItemType: Int {
    case header, expandableRow, row
}

enum SidebarSection: Int {
    case records, territories
}

struct SidebarItem: Hashable, Identifiable {
    let id: String
    private(set) var object: NSManagedObject? = nil
    private(set) var type: SidebarItemType
    private(set) var image: UIImage? = nil
    private(set) var title: String? = nil
    private(set) var subtitle: String? = nil
    private(set) var tintColor: UIColor? = nil
    private(set) var hasExpander: Bool = false
    private(set) var hasChild: Bool = false

    static func header(
        title: String,
        hasExpander: Bool = true,
        id: String = UUID().uuidString
    ) -> Self {
        SidebarItem(id: id, type: .header, title: title, hasExpander: hasExpander)
    }

    static func expandableRow(
        image: UIImage? = nil,
        title: String,
        subtitle: String? = nil,
        tintColor: UIColor? = nil,
        hasExpander: Bool = true,
        id: String = UUID().uuidString,
        object: NSManagedObject? = nil
    ) -> SidebarItem {
        SidebarItem(
            id: id,
            object: object,
            type: .expandableRow,
            image: image,
            title: title,
            subtitle: subtitle,
            tintColor: tintColor,
            hasExpander: hasExpander
        )
    }

    static func row(
        image: UIImage? = nil,
        title: String,
        subtitle: String? = nil,
        tintColor: UIColor? = nil,
        hasChild: Bool = false,
        id: String = UUID().uuidString,
        object: NSManagedObject? = nil
    ) -> SidebarItem {
        SidebarItem(
            id: id,
            object: object,
            type: .row,
            image: image,
            title: title,
            subtitle: subtitle,
            tintColor: tintColor,
            hasChild: hasChild
        )
    }
}
