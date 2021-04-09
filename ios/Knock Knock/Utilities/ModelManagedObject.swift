//
//  ModelManagedObject.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/28/21.
//

import Foundation

protocol ModelManagedObject {
    var wrappedID: String { get }
    var wrappedDateCreated: Date { get }
    var wrappedDateUpdated: Date { get }

    func willCreate()
    func willUpdate()
}
