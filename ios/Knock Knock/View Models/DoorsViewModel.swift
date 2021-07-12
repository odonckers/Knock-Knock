//
//  DoorsViewModel.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/14/21.
//

import CoreData
import Combine
import UIKit

class DoorsViewModel: ObservableObject {
    typealias Snapshot = NSDiffableDataSourceSnapshot<VisitSymbol, CollectionItem>

    let moc: NSManagedObjectContext
    let record: Record

    init(moc: NSManagedObjectContext, record: Record) {
        self.moc = moc
        self.record = record

//        $doorsSnapshot.applyingChanges(doorChanges) { door in self.recordRow(record: record) }
//            .assign(to: \.doorsSnapshot, on: self)
//            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var doorsSnapshot = Snapshot()
    private var doorChanges: AnyPublisher<CollectionDifference<Door>, Never> {
        let fetchRequest: NSFetchRequest = Door.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Door.number, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "record == %@", record)
        return moc.changesPublisher(for: fetchRequest)
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
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
