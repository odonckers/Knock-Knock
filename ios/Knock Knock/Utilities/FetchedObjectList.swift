//
//  FetchedObjectList.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import Combine
import CoreData
import Foundation

class FetchedObjectList<Object: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    let fetchedResultsController: NSFetchedResultsController<Object>
    private let onContentChange = PassthroughSubject<(), Never>()
    private let onObjectChange = PassthroughSubject<Object, Never>()

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
        } catch {
            NSLog("Error fetching objects: \(error)")
        }
    }

    var objects: [Object] { fetchedResultsController.fetchedObjects ?? [] }
    var sections: [NSFetchedResultsSectionInfo] { fetchedResultsController.sections ?? [] }
    var contentDidChange: AnyPublisher<(), Never> { onContentChange.eraseToAnyPublisher() }
    var objectDidChange: AnyPublisher<Object, Never> { onObjectChange.eraseToAnyPublisher() }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        onContentChange.send()
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
