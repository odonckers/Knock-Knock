//
//  RecordFormViewModel.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Combine
import CoreData
import CoreLocation
import SwiftUI

class RecordFormViewModel: ObservableObject {
    private var record: Record? = nil
    private var territory: Territory? = nil
    
    var isApartment: Bool {
        selectedTypeIndex == 1
    }
    var canSave: Bool {
        if isApartment {
            return streetName != "" && apartmentNumber != ""
        } else {
            return streetName != ""
        }
    }
    
    @Published var title = "New Record"
    
    @Published var selectedTypeIndex = 0
    @Published var streetName = ""
    @Published var city = ""
    @Published var state = ""
    @Published var apartmentNumber = ""
    
    @Published var location = LocationManager()
        
    init(record: Record? = nil, territory: Territory? = nil) {
        self.record = record
        self.territory = territory
        
        if let record = record {
            title = "Edit Record"
            
            switch record.wrappedType {
            case .apartment:
                selectedTypeIndex = 1
            default:
                selectedTypeIndex = 0
            }
            
            if let streetName = record.streetName {
                self.streetName = streetName
            }
            
            if let city = record.city {
                self.city = city
            }
            
            if let state = record.state {
                self.state = state
            }
                        
            if let apartmentNumber = record.apartmentNumber {
                self.apartmentNumber = apartmentNumber
            }
        }
    }
        
    func save(viewContext: NSManagedObjectContext) {
        var toSave: Record
        if let record = record {
            toSave = record
        } else {
            toSave = Record(context: viewContext)
            toSave.uuid = UUID().uuidString
            toSave.dateCreated = Date()
        }
        
        toSave.dateUpdated = Date()
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.setType(isApartment ? .apartment : .street)
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.territory = territory
        
        viewContext.unsafeSave()
    }
    
    func useCurrentLocation() {
        location.whenAuthorized { placemark in
            if let streetName = placemark?.thoroughfare {
                self.streetName = streetName
            }
            
            if let city = placemark?.locality {
                self.city = city
            }
            
            if let state = placemark?.administrativeArea {
                self.state = state
            }
        }
    }
}
