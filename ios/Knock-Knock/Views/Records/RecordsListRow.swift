//
//  RecordsListRow.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import SwiftUI

extension RecordsView {
    struct LclRow: View {
        @ObservedObject var record: Record

        var body: some View {
            HStack {
                Tag(color: record.typeColor) {
                    Text(record.abbreviatedType)
                        .frame(width: 65)
                }

                VStack(alignment: .leading) {
                    HStack {
                        if record.wrappedType == .apartment,
                           let apartmentNumber = record.apartmentNumber {
                            Text(apartmentNumber)
                        }

                        Text(record.wrappedStreetName)
                    }
                    .font(.headline)

                    if (record.city != "" || record.state != "") {
                        HStack {
                            if let city = record.city { Text(city) }
                            if let state = record.state { Text(state) }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondaryLabel)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }
}

#if DEBUG
struct RecordsListRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let record = Record(context: viewContext)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        let recordTypeApartment = Record(context: viewContext)
        recordTypeApartment.wrappedType = .apartment
        recordTypeApartment.streetName = "Street Name"
        recordTypeApartment.city = "City"
        recordTypeApartment.state = "State"
        recordTypeApartment.apartmentNumber = "500"

        return Group {
            RecordsView.LclRow(record: record)
            RecordsView.LclRow(record: recordTypeApartment)
        }
        .frame(width: 414, alignment: .leading)
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
    }
}
#endif
