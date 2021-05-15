//
//  DoorsViewModel.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/14/21.
//

import CoreData
import Foundation

class DoorsViewModel: ObservableObject {
    let moc: NSManagedObjectContext
    let record: Record

    init(moc: NSManagedObjectContext, record: Record) {
        self.moc = moc
        self.record = record
    }

    lazy var fetchedDoorsList: FetchedObjectList = makeFetchedDoorsList()
}

extension DoorsViewModel {
    private func makeFetchedDoorsList() -> FetchedObjectList<Door> {
        let fetchRequest: NSFetchRequest = Door.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Door.number, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "record == %@", record)

        return FetchedObjectList(
            fetchRequest: fetchRequest,
            moc: moc,
            sectionNameKeyPath: #keyPath(Door.latestVisit.wrappedSymbol)
        )
    }
}
