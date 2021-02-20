//
//  DoorsViewTitle.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension DoorsView {
    struct DoorsViewTitle: View {
        let record: Record
        
        var body: some View {
            HStack {
                Tag(color: record.typeColor) {
                    Text(record.abbreviatedType)
                        .frame(width: 44)
                }
                
                Spacer()
                    .frame(width: 16)
                
                if let apartmentNumber = record.apartmentNumber {
                    Text(apartmentNumber)
                }
                
                Text(record.wrappedStreetName)
            }
            .font(Font.body.bold())
        }
    }
}

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
                        DoorsView.DoorsViewTitle(record: record)
                    }
                }
        }
    }
}
