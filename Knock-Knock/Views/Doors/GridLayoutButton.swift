//
//  GridLayoutButton.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

enum GridLayoutOptions: String, Identifiable, CaseIterable {
    var id: String { rawValue }

    case grid
    case list
}

struct GridLayoutButton: View {
    @Binding var selectedGridLayout: GridLayoutOptions

    init(selectedGridLayout: Binding<GridLayoutOptions> = .constant(.grid)) {
        _selectedGridLayout = selectedGridLayout
    }

    private let options: [GridLayoutOptions: (String, String)] = [
        .grid: ("Grid", "square.grid.3x2.fill"),
        .list: ("List", "rectangle.grid.1x2.fill")
    ]

    var body: some View {
        Menu {
            Picker("Layout", selection: $selectedGridLayout.animation()) {
                ForEach(GridLayoutOptions.allCases, id: \.id) { value in
                    let option = options[value]!
                    Label(option.0, systemImage: option.1)
                        .tag(value)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.title2)
        }
    }
}
