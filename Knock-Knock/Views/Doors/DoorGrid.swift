//
//  DoorGrid.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

let kDoorGridLayout = "doorGrid.layout"

extension DoorsView {
    struct DoorGrid: View {
        @Binding private var selectedGridLayout: Int
        
        init(
            selectedGridLayout: Binding<Int> = .constant(
                GridLayoutOptions.grid.rawValue
            )
        ) {
            _selectedGridLayout = selectedGridLayout
        }
        
        @Environment(\.horizontalSizeClass) private var horizontalSize
        @Environment(\.verticalSizeClass) private var verticalSize
        
        private var inPortrait: Bool {
            horizontalSize == .compact && verticalSize == .regular
        }
        
        private var isGrid: Bool {
            selectedGridLayout == GridLayoutOptions.grid.rawValue
        }
        
        private let sectionHeaders: [(String, String, String)] = [
            ("Not-at-Homes", "house.fill", "NotAtHomeColor"),
            ("Busy", "megaphone.fill", "BusyColor"),
            ("Call Again", "person.fill.checkmark", "CallAgainColor"),
            ("Not Interested", "person.fill.xmark", "NotInterestedColor"),
            ("Other", "dot.squareshape.fill", "OtherColor")
        ]
        
        private var gridColumns: [GridItem] {
            let gridColumnItem = GridItem(
                .flexible(),
                spacing: 8,
                alignment: .top
            )
            
            let portraitColumns = [gridColumnItem, gridColumnItem]
            let landscapeColumns = [
                gridColumnItem,
                gridColumnItem,
                gridColumnItem
            ]
            
            let gridColumns = inPortrait ? portraitColumns : landscapeColumns
            let listColumns = [gridColumnItem]

            return isGrid ? gridColumns : listColumns
        }
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(sectionHeaders, id: \.0) { header in
                        let groupLabel = Label(
                            header.0,
                            systemImage: header.1
                        )
                        .foregroundColor(Color(header.2))
                        
                        GroupBox(label: groupLabel) {
                            ForEach(0..<header.0.count) { index in
                                Text("Index \(index)")
                            }
                        }
                        .groupBoxStyle(CardGroupBoxStyle())
                    }
                }
                .padding()
            }
        }
    }
}

struct DoorGrid_Previews: PreviewProvider {
    static var previews: some View {
        DoorsView.DoorGrid()
            .background(Color("GroupedBackgroundColor"))
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
            .previewLayout(.sizeThatFits)
    }
}
