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

    @ObservedObject private var sheet = SheetState<SheetStates>()

    var body: some View {
        RecordList(territory: territory)
            .navigationTitle(territory?.wrappedName ?? "Records")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { sheet.present(.recordForm) }) {
                        Label("Add Record", systemImage: "note.text.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $sheet.isPresented) {
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
            .environmentObject(sheet)
    }
}

extension RecordsView {
    enum SheetStates {
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
