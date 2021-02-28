//
//  TerritoryList.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import SwiftUI

struct TerritoryList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @EnvironmentObject
    private var sheet: SheetState<TerritoriesView.SheetStates>

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ],
        animation: .default
    )
    private var territories: FetchedResults<Territory>

    @SceneStorage("Territory.selection")
    private var selection: String? // Territory UUID

    var body: some View {
        List(
            territories,
            id: \.wrappedID,
            selection: $selection
        ) { territory in
            NavigationLink(
                destination: RecordsView(territory: territory),
                tag: territory.wrappedID,
                selection: $selection
            ) {
                TerritoryRow(territory: territory)
            }
            .contextMenu {
                Button(action: {
                    sheet.present(.territoryForm, with: territory)
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Menu {
                    Button(action: { delete(territory) }) {
                        Label("Permenantly Delete", systemImage: "trash")
                    }
                } label: {
                    Label("Delete Territory", systemImage: "trash")
                }
            }
        }
    }

    private func delete(_ item: NSManagedObject) {
        withAnimation {
            viewContext.delete(item)
            viewContext.unsafeSave()
        }
    }
}

#if DEBUG
struct TerritoryList_Previews: PreviewProvider {
    static var previews: some View {
        TerritoryList()
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
            .previewLayout(.sizeThatFits)
    }
}
#endif
