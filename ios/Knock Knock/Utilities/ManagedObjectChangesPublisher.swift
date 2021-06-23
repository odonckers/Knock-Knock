//
//  ManagedObjectChangesPublisher.swift
//  Knock Knock
//
//  Created by Owen Donckers on 6/21/21.
//

import Combine
import CoreData
import Foundation

extension NSManagedObjectContext {
    func changesPublisher<Object>(
        for fetchRequest: NSFetchRequest<Object>
    ) -> ManagedObjectChangesPublisher<Object>
    where Object: NSManagedObject {
        ManagedObjectChangesPublisher(fetchRequest: fetchRequest, moc: self)
    }
}

struct ManagedObjectChangesPublisher<Object>: Publisher
where Object: NSManagedObject {
    typealias Output = CollectionDifference<Object>
    typealias Failure = Error

    let fetchRequest: NSFetchRequest<Object>
    let moc: NSManagedObjectContext

    init(fetchRequest: NSFetchRequest<Object>, moc: NSManagedObjectContext) {
        self.fetchRequest = fetchRequest
        self.moc = moc
    }

    func receive<S>(subscriber: S)
    where S : Subscriber, Error == S.Failure, CollectionDifference<Object> == S.Input {
        let inner = Inner(downstream: subscriber, fetchRequest: fetchRequest, moc: moc)
        subscriber.receive(subscription: inner)
    }
}

extension ManagedObjectChangesPublisher {
    private final class Inner<Downstream>: NSObject,
                                           Subscription,
                                           NSFetchedResultsControllerDelegate
    where Downstream: Subscriber,
          Downstream.Input == CollectionDifference<Object>,
          Downstream.Failure == Error
    {
        private let downstream: Downstream
        private var fetchedResultsController: NSFetchedResultsController<Object>?

        init(
            downstream: Downstream,
            fetchRequest: NSFetchRequest<Object>,
            moc: NSManagedObjectContext
        ) {
            self.downstream = downstream
            fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: moc,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

            super.init()

            fetchedResultsController!.delegate = self
            do {
                try fetchedResultsController!.performFetch()
                updateDiff()
            } catch {
                downstream.receive(completion: .failure(error))
            }
        }

        private var demand: Subscribers.Demand = .none
        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
            fulfillDemand()
        }

        func cancel() {
            fetchedResultsController?.delegate = nil
            fetchedResultsController = nil
        }

        private var lastSentState: [Object] = []
        private var currentDifferences = CollectionDifference<Object>([])!

        private func updateDiff() {
            currentDifferences = Array(fetchedResultsController?.fetchedObjects ?? [])
                .difference(from: lastSentState)
            fulfillDemand()
        }

        private func fulfillDemand() {
            if demand > 0 && !currentDifferences.isEmpty {
                let newDemand = downstream.receive(currentDifferences)

                lastSentState = Array(fetchedResultsController?.fetchedObjects ?? [])
                currentDifferences = lastSentState.difference(from: lastSentState)

                demand += newDemand
                demand -= 1
            }
        }

        func controllerDidChangeContent(
            _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
            updateDiff()
        }

        override var description: String { "ManagedObjectChanges(\(Object.self))" }
    }
}
