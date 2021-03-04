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
    @Environment(\.managedObjectContext)
    private var viewContext

    @State private var hasLoaded = false

    var body: some View {
        NavigationView {
            sidebar
                .sheet(isPresented: $sheet.isPresented, content: sheetContent)

            RecordsView()

            Text("doors.selectRecord")
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

    // MARK: - Sidebar

    @State private var selection: String?

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
        .navigationTitle("general.home")
    }

    // MARK: - Territories Section

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Territory.name, ascending: true)
        ],
        animation: .default
    )
    private var territories: FetchedResults<Territory>

    @ViewBuilder private var territoriesSection: some View {
        Section(
            header: Text("territories.title")
                .foregroundColor(.label)
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
                        Label("general.edit", systemImage: "pencil")
                    }
                    Menu {
                        Button(action: { delete(territory) }) {
                            Label(
                                "general.permenantlyDelete",
                                systemImage: "trash"
                            )
                        }
                    } label: {
                        Label("territories.delete", systemImage: "trash")
                    }
                }
            }

            Button(action: { sheet.present(.territoryForm) }) {
                Label("territories.add", systemImage: "plus.circle")
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
