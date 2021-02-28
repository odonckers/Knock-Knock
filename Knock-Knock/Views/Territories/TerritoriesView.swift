//
//  TerritoriesView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct TerritoriesView: View {
    @ObservedObject private var sheet = SheetState<SheetStates>()

    var body: some View {
        TerritoryList()
            .navigationTitle("Territories")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { sheet.present(.territoryForm) }) {
                        Label(
                            "Add Territory",
                            systemImage: "folder.fill.badge.plus"
                        )
                    }
                }
            }
            .sheet(isPresented: $sheet.isPresented) {
                switch sheet.state {
                case .territoryForm:
                    TerritoryFormView(
                        territory: sheet.arguments as? Territory ?? nil
                    )
                default:
                    EmptyView()
                }
            }
            .environmentObject(sheet)
    }
}

extension TerritoriesView {
    enum SheetStates {
        case territoryForm
    }
}

#if DEBUG
struct TerritoriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TerritoriesView()
                .listStyle(PlainListStyle())
        }
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
    }
}
#endif
