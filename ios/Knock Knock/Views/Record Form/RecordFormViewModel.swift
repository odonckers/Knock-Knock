//
//  RecordFormViewModel.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import CoreData
import Foundation

class RecordFormViewModel: ObservableObject {
    var record: Record?
    @Published var territory: Territory?

    init(record: Record? = nil, territory: Territory? = nil) {
        self.record = record
        self.territory = territory

        if let record = record {
            selectedTypeIndex = Int(record.wrappedType.rawValue)

            if let streetName = record.streetName {
                self.streetName = streetName
            }
            if let city = record.city { self.city = city }
            if let state = record.state { self.state = state }
            if let apartmentNumber = record.apartmentNumber {
                self.apartmentNumber = apartmentNumber
            }
        }
    }

    @Published var selectedTypeIndex = 0
    @Published var streetName = ""
    @Published var city = ""
    @Published var state = ""
    @Published var apartmentNumber = ""

    var isApartment: Bool { selectedTypeIndex == 1 }
    var canSave: Bool {
        if isApartment { return streetName != "" && apartmentNumber != "" }
        else { return streetName != "" }
    }

    func save(in moc: NSManagedObjectContext) {
        var toSave: Record
        if let record = record {
            toSave = record
            toSave.willUpdate()
        } else {
            toSave = Record(context: moc)
            toSave.willCreate()
        }

        toSave.wrappedType = isApartment ? .apartment : .street
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.territory = territory

        moc.unsafeSave()
    }
}
