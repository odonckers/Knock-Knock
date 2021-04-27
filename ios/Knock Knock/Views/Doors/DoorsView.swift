//
//  DoorsView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct DoorsView: View {
    @ObservedObject var record: Record

    @Environment(\.horizontalSizeClass) private var horizontalSize
    @Environment(\.verticalSizeClass) private var verticalSize
    @Environment(\.uiNavigationController) private var navigationController

    private var inPortrait: Bool { horizontalSize == .compact && verticalSize == .regular }
    private var isCompact: Bool {
        horizontalSize == .compact || UIDevice.current.userInterfaceIdiom == .phone
    }

    @State private var selectedGridLayout: GridLayoutOptions = .grid
    private var gridColumns: [GridItem] {
        let gridColumnItem = GridItem(.flexible(), spacing: 8, alignment: .top)

        let portraitColumns = (1...2).map { _ in gridColumnItem }
        let landscapeColumns = (1...3).map { _ in gridColumnItem }

        let gridColumns = inPortrait ? portraitColumns : landscapeColumns
        let listColumns = [gridColumnItem]

        return selectedGridLayout == .grid ? gridColumns : listColumns
    }

    private let sectionHeaders: [(String, String, Color)] = [
        ("Not-at-Homes", "house.fill", .visitSymbolNotAtHome),
        ("Busy", "megaphone.fill", .visitSymbolBusy),
        ("Call Again", "person.fill.checkmark", .visitSymbolCallAgain),
        ("Not Interested", "person.fill.xmark", .visitSymbolNotInterested),
        ("Other", "dot.squareshape.fill", .visitSymbolOther),
    ]

    @State private var isSelected = false

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns) {
                ForEach(sectionHeaders, id: \.0) { text, image, color in
                    let groupLabel = Label(text, systemImage: image)
                        .foregroundColor(color)

                    Button(action: { withAnimation { isSelected.toggle() } }) {
                        GroupBox(label: groupLabel) {
                            ForEach(0..<text.count) { index in
                                Text("Index \(index)")
                            }
                        }
                        .groupBoxStyle(
                            CardGroupBoxStyle {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) { toolbarTitle }
            ToolbarItem { gridLayoutButton }
        }
        .filledBackground(Color.groupedBackground)
    }

    // MARK: - Toolbar Title

    @ViewBuilder private var toolbarTitle: some View {
        HStack(alignment: .center, spacing: 10) {
            Tag(text: record.abbreviatedType, backgroundColor: record.typeColor)
                .foregroundColor(record.typeColor)
            Text(record.wrappedStreetName)
                .font(.headline)
        }
    }

    // MARK: - Grid Layout Button

    private let options: [GridLayoutOptions: (String, String)] = [
        .grid: ("Grid", "square.grid.3x2.fill"),
        .list: ("List", "rectangle.grid.1x2.fill")
    ]

    @ViewBuilder private var picker: some View {
        Picker("Layout", selection: $selectedGridLayout.animation()) {
            ForEach(GridLayoutOptions.allCases, id: \.id) { value in
                let option = options[value]!
                Label(option.0, systemImage: option.1)
                    .tag(value)
            }
        }
    }

    @ViewBuilder private var gridLayoutButton: some View {
        if isCompact {
            Menu { picker } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.title2)
            }
        } else {
            picker.pickerStyle(InlinePickerStyle())
        }
    }

    // MARK: - Empty Body

    @ViewBuilder static var emptyBody: some View {
        VStack(alignment: .center) {
            Text("Select a Record")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}

extension DoorsView {
    private enum GridLayoutOptions: String, Identifiable, CaseIterable {
        var id: String { rawValue }
        case grid, list
    }
}

#if DEBUG
struct DoorsView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext

        let record = Record(context: moc)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        return EnvironmentUIPreviewWrapper { DoorsView(record: record) }
    }
}
#endif
