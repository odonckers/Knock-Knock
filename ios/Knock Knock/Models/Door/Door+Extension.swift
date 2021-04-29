//
//  Door+Extension.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Door {
    public var wrappedNumber: String { number ?? "" }
    public var wrappedVisitSymbol: VisitSymbol {
        get { VisitSymbol(rawValue: visitSymbol) ?? .notAtHome }
        set { visitSymbol = newValue.rawValue }
    }
    public var visitArray: [Visit] {
        let set = visits as? Set<Visit> ?? []
        return set.sorted { $0.wrappedDate < $1.wrappedDate }
    }
    @objc public var latestVisit: Visit? {
        visitArray.count <= 1 ? visitArray.first : nil
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
