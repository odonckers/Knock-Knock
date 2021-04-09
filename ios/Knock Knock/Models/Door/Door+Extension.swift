//
//  Door+Extension.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Door {
    public var wrappedNumber: String { number ?? "" }
    public var wrappedAttemptSymbol: AttemptSymbol {
        get { AttemptSymbol(rawValue: attemptSymbol) ?? .notAtHome }
        set { attemptSymbol = newValue.rawValue }
    }
    public var attemptArray: [Attempt] {
        let set = attempts as? Set<Attempt> ?? []
        return set.sorted { $0.wrappedDate < $1.wrappedDate }
    }
    public var latestAttempt: Attempt? {
        attemptArray.count <= 1 ? attemptArray.first : nil
    }
}

extension Door: ModelManagedObject {
    public var wrappedID: String { uuid ?? UUID().uuidString }
    public var wrappedDateCreated: Date { dateCreated ?? Date() }
    public var wrappedDateUpdated: Date { dateUpdated ?? Date() }

    public func willCreate() {
        uuid = UUID().uuidString
        dateCreated = Date()
        dateUpdated = dateCreated
    }

    public func willUpdate() { dateUpdated = Date() }
}
