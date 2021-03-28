//
//  DoorsView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct DoorsView: View {
    let record: Record

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns) {
                ForEach(sectionHeaders, id: \.0) { header in
                    let groupLabel = Label(header.0, systemImage: header.1)
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
        .toolbar {
            ToolbarItem(placement: .principal) { title }
            ToolbarItem {
                GridLayoutButton(selectedGridLayout: $selectedGridLayout)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .filledBackground(Color.groupedBackground)
        .navigationBarBackButtonHidden(!inPortrait)
    }

    @Environment(\.horizontalSizeClass)
    private var horizontalSize

    @Environment(\.verticalSizeClass)
    private var verticalSize

    // MARK: - Grid

    @State private var selectedGridLayout: GridLayoutOptions = .grid

    private var inPortrait: Bool {
        horizontalSize == .compact && verticalSize == .regular
    }
    private var isGrid: Bool { selectedGridLayout == .grid }

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

    // MARK: - Title

    @ViewBuilder private var title: some View {
        HStack {
            Tag(color: record.typeColor) {
                Text(record.abbreviatedType)
                    .frame(width: 65)
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
#endif
