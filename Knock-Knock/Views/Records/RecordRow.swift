//
//  RecordRow.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import SwiftUI

struct RecordRow: View {
    @ObservedObject var record: Record
        
    var body: some View {
        HStack {
            Tag(color: record.typeColor) {
                Text(record.abbreviatedType)
                    .frame(width: 44)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    if record.wrappedType == .apartment, let apartmentNumber = record.apartmentNumber {
                        Text(apartmentNumber)
                    }
                    
                    Text(record.wrappedStreetName)
                }
                .font(.headline)
                
                if (record.city != "" || record.state != "") {
                    HStack {
                        if let city = record.city {
                            Text(city)
                        }
                        
                        if let state = record.state {
                            Text(state)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(
                        Color("SecondaryLabelColor")
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
}

struct RecordCell_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext
        
        let record = Record(context: viewContext)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"
        
        let apartment = Record(context: viewContext)
        apartment.streetName = "Street Name"
        apartment.city = "City"
        apartment.state = "State"
        apartment.apartmentNumber = "500"
        apartment.setType(.apartment)
        
        return Group {
            RecordRow(record: record)
            
            RecordRow(record: apartment)
        }
        .frame(width: 414, alignment: .leading)
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
    }
}

