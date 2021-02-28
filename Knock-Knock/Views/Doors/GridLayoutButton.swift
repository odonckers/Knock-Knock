//
//  GridLayoutButton.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

enum GridLayoutOptions: Int {
    case grid = 0
    case list = 1
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
                ForEach(0..<options.count) { i in
                    let gridLayout = Array(options.keys)[i]
                    let option = options[gridLayout]!
                    Label(option.0, systemImage: option.1)
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
                .font(.title2)
        }
    }
}
