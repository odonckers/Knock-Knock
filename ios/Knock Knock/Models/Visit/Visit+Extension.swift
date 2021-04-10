//
//  Visit+Extension.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Visit {
    public var wrappedDate: Date { date ?? Date() }
    public var wrappedSymbol: VisitSymbol {
        get { VisitSymbol(rawValue: symbol) ?? .notAtHome }
        set { symbol = newValue.rawValue }
    }
    public var wrappedPerson: VisitPerson {
        get { VisitPerson(rawValue: person) ?? .nobody }
        set { person = newValue.rawValue }
    }
}

extension Visit: ModelManagedObject {
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
