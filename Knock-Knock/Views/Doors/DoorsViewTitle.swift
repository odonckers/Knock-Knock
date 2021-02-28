//
//  DoorsViewTitle.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct DoorsViewTitle: View {
    let record: Record

    var body: some View {
        HStack {
            Tag(color: record.typeColor) {
                Text(record.abbreviatedType)
                    .frame(width: 44)
            }
            FramedSpacer(spacing: .medium, direction: .horizontal)
            if let apartmentNumber = record.apartmentNumber {
                Text(apartmentNumber)
            }
            Text(record.wrappedStreetName)
        }
        .font(Font.body.bold())
    }
}

#if DEBUG
struct DoorsViewTitle_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let record = Record(context: viewContext)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        return NavigationView {
            EmptyView()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        DoorsViewTitle(record: record)
                    }
                }
        }
    }
}
#endif
