//
//  RecordRow.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/19/21.
//

import SwiftUI

struct RecordRow: View {
    @ObservedObject var record: Record
    var isSelected = false

    private var subtitle: String? {
        var secondaryTexts: [String] = []
        if let city = record.city, city != "" { secondaryTexts.append(city) }
        if let state = record.state, state != "" { secondaryTexts.append(state) }

        if secondaryTexts.count == 0 { return nil }

        let subtitle = secondaryTexts.joined(separator: ", ")
        return subtitle
    }

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Tag(
                text: record.abbreviatedType,
                backgroundColor: isSelected ? Color.black.opacity(0.9) : record.typeColor
            )
            .foregroundColor(isSelected ? .white : record.typeColor)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if let apartmentNumber = record.apartmentNumber { Text(apartmentNumber) }
                    Text(record.wrappedStreetName)
                }
                .font(.headline)
                .foregroundColor(isSelected ? .white : nil)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundColor(isSelected ? Color.white.opacity(0.7) : .gray)
                }
            }

            Spacer()
        }
    }
}

#if DEBUG
struct RecordCellView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext

        let record = Record(context: moc)
        record.wrappedType = .apartment
        record.streetName = "Street name"
        record.city = "City"
        record.state = "State"
        record.apartmentNumber = "500"

        return Group {
            RecordRow(record: record, isSelected: false)
            RecordRow(record: record, isSelected: true)
                .background(Color.accentColor)
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}
#endif
