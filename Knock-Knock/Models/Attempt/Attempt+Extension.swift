//
//  Attempt+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Attempt {
    public var wrappedUuid: String { uuid ?? UUID().uuidString }
    public var wrappedDateCreated: Date { dateCreated ?? Date() }
    public var wrappedDateUpdated: Date { dateUpdated ?? Date() }
    public var wrappedDate: Date { date ?? Date() }
    public var wrappedSymbol: AttemptSymbol {
        AttemptSymbol(rawValue: symbol) ?? .notAtHome
    }
    public var wrappedPerson: AttemptPerson {
        AttemptPerson(rawValue: person) ?? .nobody
    }

    public func setSymbol(_ symbol: AttemptSymbol) {
        self.symbol = symbol.rawValue
    }

    public func setPerson(_ person: AttemptPerson) {
        self.person = person.rawValue
    }
}
