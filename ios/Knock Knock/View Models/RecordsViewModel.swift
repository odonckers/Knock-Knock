//
//  RecordsViewModel.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import CoreData
import Foundation

class RecordsViewModel: ObservableObject {
    let moc: NSManagedObjectContext

    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    lazy var fetchedRecordsList: FetchedObjectList = makeFetchedRecordsList()
    lazy var fetchedTerritoriesList: FetchedObjectList = makeFetchedTerritoriesList()
}

extension RecordsViewModel {
    func makeFetchedRecordsList() -> FetchedObjectList<Record> {
        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "territory == NULL")

        return FetchedObjectList(fetchRequest: fetchRequest, moc: moc)
    }

    func makeFetchedTerritoriesList() -> FetchedObjectList<Territory> {
        let fetchRequest: NSFetchRequest = Territory.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ]

        return FetchedObjectList(fetchRequest: fetchRequest, moc: moc)
    }
}

extension RecordsViewModel {
    func saveRecord(
        type: RecordType = .street,
        streetName: String,
        city: String = "",
        state: String = "",
        apartmentNumber: String = "",
        territory: Territory? = nil,
        to record: Record? = nil
    ) {
        let isApartment = type == .apartment

        var toSave: Record
        if let record = record {
            toSave = record
            toSave.willUpdate()
        } else {
            toSave = Record(context: moc)
            toSave.willCreate()
        }

        toSave.wrappedType = isApartment ? .apartment : .street
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.territory = territory

        moc.unsafeSave()
    }

    func moveRecord(_ record: Record, to territory: Territory?) {
        record.willUpdate()
        record.territory = territory

        moc.unsafeSave()
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
