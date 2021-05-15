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
    private func makeFetchedRecordsList() -> FetchedObjectList<Record> {
        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "territory == NULL")

        return FetchedObjectList(fetchRequest: fetchRequest, moc: moc)
    }

    private func makeFetchedTerritoriesList() -> FetchedObjectList<Territory> {
        let fetchRequest: NSFetchRequest = Territory.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ]

        return FetchedObjectList(fetchRequest: fetchRequest, moc: moc)
    }
}

extension RecordsViewModel {
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
