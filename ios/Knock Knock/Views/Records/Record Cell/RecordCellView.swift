//
//  RecordCellView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/19/21.
//

import SwiftUI

struct RecordCellView: View {
    var record: Record
    var isSelected = false

    var body: some View {
        var secondaryTexts: [String] = []
        if let city = record.city, city != "" {
            secondaryTexts.append(city)
        }
        if let state = record.state, state != "" {
            secondaryTexts.append(state)
        }
        let subtitle = secondaryTexts.joined(separator: ", ")

        return HStack(alignment: .center, spacing: 20) {
            Tag(
                text: record.abbreviatedType,
                backgroundColor: isSelected
                    ? Color.black.opacity(0.9)
                    : record.typeColor
            )
            .foregroundColor(isSelected ? .white : record.typeColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.wrappedStreetName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : nil)

                if let subtitle = subtitle, subtitle != "" {
                    Text(subtitle)
                        .font(.callout)
                        .foregroundColor(
                            isSelected
                                ? Color.white.opacity(0.7)
                                : .gray
                        )
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
            RecordCellView(record: record, isSelected: false)
            RecordCellView(record: record, isSelected: true)
                .background(Color.accentColor)
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}
#endif
