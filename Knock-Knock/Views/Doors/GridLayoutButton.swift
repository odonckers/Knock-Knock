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

extension DoorsView {
    struct GridLayoutButton: View {
        @Binding private var selectedGridLayout: Int
        
        init(selectedGridLayout: Binding<Int> = .constant(GridLayoutOptions.grid.rawValue)) {
            _selectedGridLayout = selectedGridLayout
        }
        
        private let options: [Int: (String, String)] = [
            GridLayoutOptions.grid.rawValue: (
                "Grid",
                "square.grid.3x2.fill"
            ),
            GridLayoutOptions.list.rawValue: (
                "List",
                "rectangle.grid.1x2.fill"
            )
        ]
            
        var body: some View {
            Menu {
                Picker(
                    "Layout",
                    selection: $selectedGridLayout.animation()
                ) {
                    ForEach(0..<options.count) {
                        let option = options[$0]!
                        Label(option.0, systemImage: option.1)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.title2)
            }
        }
    }
}
