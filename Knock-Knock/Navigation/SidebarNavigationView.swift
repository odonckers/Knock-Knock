//
//  SidebarNavigationView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import Introspect
import SwiftUI

struct SidebarNavigationView: View {
    // MARK: - Sidebar

    @SceneStorage("SidebarNavigation.selection")
    private var selection: String?

    @ViewBuilder private var sidebar: some View {
        List(selection: $selection) {
            NavigationLink(
                destination: RecordsView(),
                tag: NavigationItem.recordList.value,
                selection: $selection
            ) {
                RecordsLabel()
            }
            territoriesSection
        }
        .listStyle(SidebarListStyle())
        .introspectTableView { tableView in
            tableView.backgroundColor = .secondarySystemBackground
        }
        .navigationTitle("Home")
    }

    // MARK: - Territories Section

    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ],
        animation: .default
    )
    private var territories: FetchedResults<Territory>

    @ViewBuilder private var territoriesSection: some View {
        Section(
            header: Text("Territories")
                .foregroundColor(Color("LabelColor"))
        ) {
            ForEach(territories, id: \.self) { territory in
                let tag = NavigationItem.territory(territory).value

                NavigationLink(
                    destination: RecordsView(territory: territory),
                    tag: tag,
                    selection: $selection
                ) {
                    Label(territory.wrappedName, systemImage: "folder")
                }
                .contextMenu {
                    Button(
                        action: {
                            sheet.present(.territoryFormEdit, with: territory)
                        }
                    ) {
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

            Button(action: { sheet.present(.territoryForm) }) {
                Label("Add Territory", systemImage: "plus.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func delete(_ item: NSManagedObject) {
        withAnimation {
            viewContext.delete(item)
            viewContext.unsafeSave()
        }
    }

    // MARK: - Sheet Contents

    @ObservedObject private var sheet = SheetState<SheetStates>()

    @ViewBuilder private var sheetContents: some View {
        switch sheet.state {
        case .territoryForm:
            TerritoryFormView()
        case .territoryFormEdit:
            let arguments = sheet.arguments as! Territory
            TerritoryFormView(territory: arguments)
        default:
            EmptyView()
        }
    }

    private enum SheetStates {
        case none
        case territoryForm
        case territoryFormEdit
    }

    // MARK: - Body

    @State private var hasLoaded = false

    var body: some View {
        NavigationView {
            sidebar.sheet(isPresented: $sheet.isPresented) { sheetContents }
            RecordsView()
            Text("Select a Record")
                .font(.title2)
                .foregroundColor(.secondary)
                .introspectSplitViewController { splitViewController in
                    if !hasLoaded {
                        splitViewController.preferredDisplayMode = .twoDisplaceSecondary
                        splitViewController.showsSecondaryOnlyButton = true
                        splitViewController.primaryBackgroundStyle = .sidebar

                        hasLoaded.toggle()
                    }
                }
        }
    }
}

extension SidebarNavigationView {
    private enum NavigationItem {
        case recordList
        case territory(Territory)

        var value: String {
            switch self {
            case .territory(let territory):
                return "territory-" + territory.wrappedID
            default:
                return "recordList"
            }
        }
    }
}

#if DEBUG
struct SidebarNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigationView()
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
    }
}
#endif
