//
//  Record+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Record {
    public var wrappedType: RecordType {
        get { RecordType(rawValue: type) ?? .street }
        set { self.type = newValue.rawValue }
    }
    public var wrappedStreetName: String { streetName ?? "" }
    public var doorArray: [Door] {
        let set = doors as? Set<Door> ?? []
        return set.sorted { $0.wrappedNumber < $1.wrappedNumber }
    }
}

extension Record: ModelManagedObject {
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
