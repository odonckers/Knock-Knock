//
//  FetchedObjectList.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import Combine
import CoreData
import Foundation

class FetchedObjectList<Object>: NSObject, NSFetchedResultsControllerDelegate
where Object: NSManagedObject {
    let fetchedResultsController: NSFetchedResultsController<Object>

    init(
        fetchRequest: NSFetchRequest<Object>,
        moc: NSManagedObjectContext,
        sectionNameKeyPath: String? = nil
    ) {
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: moc,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )
        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            sendCurrentObjects()
        } catch {
            NSLog("Error fetching objects: \(error)")
        }
    }

    var objects: AnyPublisher<[Object], Never> { onObjectsChange.eraseToAnyPublisher() }
    var sections: [NSFetchedResultsSectionInfo] { fetchedResultsController.sections ?? [] }
    var objectDidChange: AnyPublisher<Object, Never> { onObjectChange.eraseToAnyPublisher() }

    private let onObjectChange = PassthroughSubject<Object, Never>()
    private let onObjectsChange = PassthroughSubject<[Object], Never>()

    private func sendCurrentObjects() {
        onObjectsChange.send(fetchedResultsController.fetchedObjects ?? [])
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        sendCurrentObjects()
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        onObjectChange.send(anObject as! Object)
    }
}
