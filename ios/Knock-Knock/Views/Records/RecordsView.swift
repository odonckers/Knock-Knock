//
//  RecordsView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import SwiftUI

struct RecordsView: View {
    var territory: Territory? = nil

    init(territory: Territory? = nil) {
        self.territory = territory

        var recordsPredicate = NSPredicate(format: "territory == NULL")
        if let territory = territory {
            recordsPredicate = NSPredicate(format: "territory == %@", territory)
        }

        recordsRequest = FetchRequest<Record>(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Record.streetName, ascending: true)
            ],
            predicate: recordsPredicate,
            animation: .default
        )
    }

    @Environment(\.managedObjectContext)
    private var viewContext

    var body: some View {
        List(
            records,
            id: \.wrappedID,
            selection: $selection,
            rowContent: rowContent
        )
        .navigationTitle(
            LocalizedStringKey(territory?.wrappedName ?? "records.title")
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { sheet.present(.recordForm) } label: {
                    Label("records.add", systemImage: "note.text.badge.plus")
                }
            }
        }
        .sheet(isPresented: $sheet.isPresented, content: sheetContent)
    }

    // MARK: - List

    private var recordsRequest: FetchRequest<Record>
    private var records: FetchedResults<Record> { recordsRequest.wrappedValue }

    @State private var selection: String? // Record UUID

    @ViewBuilder private func rowContent(record: Record) -> some View {
        NavigationLink(
            destination: DoorsView(record: record),
            tag: record.wrappedID,
            selection: $selection
        ) {
            LclRow(record: record)
        }
        .contextMenu {
            Button { sheet.present(.recordForm, with: record) } label: {
                Label("general.edit", systemImage: "pencil")
            }

            Menu {
                Button { delete(record) } label: {
                    Label(
                        "general.permenantlyDelete",
                        systemImage: "trash"
                    )
                }
            } label: {
                Label("records.delete", systemImage: "trash")
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
        case .recordForm:
            RecordFormView(
                record: sheet.arguments as? Record ?? nil,
                territory: territory
            )
        default:
            EmptyView()
        }
    }

    private enum SheetStates {
        case recordForm
    }
}

#if DEBUG
struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { RecordsView().listStyle(PlainListStyle()) }
            .environment(
                \.managedObjectContext,
                PersistenceController.preview.container.viewContext
            )
    }
}
#endif
