//
//  Territory+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

extension Territory {
    public var wrappedUuid: String { uuid ?? UUID().uuidString }
    public var wrappedDateCreated: Date { dateCreated ?? Date() }
    public var wrappedDateUpdated: Date { dateUpdated ?? Date() }
    public var wrappedName: String { name ?? "" }

    public var recordArray: [Record] {
        let set = records as? Set<Record> ?? []
        return set.sorted { $0.wrappedStreetName < $1.wrappedStreetName }
    }

    public var recordCount: Int {
        let set = records as? Set<Record> ?? []
        return set.count
    }
}
