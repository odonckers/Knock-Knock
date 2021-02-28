//
//  Record+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Record {
    public var wrappedUuid: String { uuid ?? UUID().uuidString }
    public var wrappedDateCreated: Date { dateCreated ?? Date() }
    public var wrappedDateUpdated: Date { dateUpdated ?? Date() }
    public var wrappedType: RecordType { RecordType(rawValue: type) ?? .street }
    public var wrappedStreetName: String { streetName ?? "" }

    public func setType(_ type: RecordType) {
        self.type = type.rawValue
    }

    public var doorArray: [Door] {
        let set = doors as? Set<Door> ?? []
        return set.sorted { $0.wrappedNumber < $1.wrappedNumber }
    }
}
