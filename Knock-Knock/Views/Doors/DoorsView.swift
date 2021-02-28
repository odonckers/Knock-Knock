//
//  DoorsView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct DoorsView: View {
    let record: Record

    @SceneStorage(kDoorGridLayout)
    private var selectedGridLayout: GridLayoutOptions = .grid

    var body: some View {
        DoorGrid(selectedGridLayout: $selectedGridLayout)
            .toolbar {
                ToolbarItem {
                    GridLayoutButton(selectedGridLayout: $selectedGridLayout)
                }
                ToolbarItem(placement: .principal) {
                    DoorsViewTitle(record: record)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .filledBackground(Color("GroupedBackgroundColor"))
    }
}

struct DoorsView_Previews: PreviewProvider {
    static var previews: some View {
        let record = Record(
            context: PersistenceController.preview.container.viewContext
        )
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        return NavigationView { DoorsView(record: record) }
    }
}
