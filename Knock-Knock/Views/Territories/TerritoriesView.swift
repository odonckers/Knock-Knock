//
//  TerritoriesView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import SwiftUI

struct TerritoriesView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    var body: some View {
        List(
            territories,
            id: \.wrappedID,
            selection: $selection,
            rowContent: rowContent
        )
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
        .sheet(isPresented: $sheet.isPresented, content: sheetContent)
    }

    // MARK: - List

    @FetchRequest<Territory>(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ],
        animation: .default
    )
    private var territories: FetchedResults<Territory>

    @State private var selection: String? // Territory UUID

    @ViewBuilder private func rowContent(territory: Territory) -> some View {
        NavigationLink(
            destination: RecordsView(territory: territory),
            tag: territory.wrappedID,
            selection: $selection
        ) {
            LclRow(territory: territory)
        }
        .contextMenu {
            Button(action: { sheet.present(.territoryForm, with: territory) }) {
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

    private func delete(_ item: NSManagedObject) {
        withAnimation {
            viewContext.delete(item)
            viewContext.unsafeSave()
        }
    }

    // MARK: - Sheet

    @ObservedObject private var sheet = SheetState<SheetStates>()

    @ViewBuilder private func sheetContent() -> some View {
        switch sheet.state {
        case .territoryForm:
            TerritoryFormView(
                territory: sheet.arguments as? Territory ?? nil
            )
        default:
            EmptyView()
        }
    }

    private enum SheetStates {
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
