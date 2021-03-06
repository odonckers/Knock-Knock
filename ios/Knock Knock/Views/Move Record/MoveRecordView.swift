//
//  MoveRecordView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/19/21.
//

import CoreData
import SwiftUI

struct MoveRecordView: View {
    var record: Record

    @Environment(\.managedObjectContext) private var moc
    @Environment(\.uiNavigationController) private var navigationController

    static private var territoryFetchRequest: NSFetchRequest<Territory> {
        let fetchRequest: NSFetchRequest = Territory.fetchRequest()
        fetchRequest.sortDescriptors = []

        return fetchRequest
    }

    @FetchRequest(fetchRequest: territoryFetchRequest)
    private var territories: FetchedResults<Territory>

    var body: some View {
        List {
            if record.territory == nil {
                HStack {
                    Label("Records", systemImage: "note.text")
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            } else {
                Button(action: {
                    move(record: record, to: nil)
                    navigationController?.dismiss(animated: true)
                }) {
                    Label("Records", systemImage: "note.text")
                }
            }

            ForEach(territories) { territory in
                if let existingTerritory = record.territory,
                   existingTerritory == territory {
                    HStack {
                        Label(territory.wrappedName, systemImage: "folder")
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                } else {
                    Button(action: {
                        move(record: record, to: territory)
                        navigationController?.dismiss(animated: true)
                    }) {
                        Label(territory.wrappedName, systemImage: "folder")
                    }
                }
            }
        }
        .navigationTitle("Select a territory")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { navigationController?.dismiss(animated: true) }) {
                    Text("cancel")
                }
            }
        }
        .navigationSubheader { RecordRow(record: record) }
        .onAppear {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

extension MoveRecordView {
    private func move(record: Record, to territory: Territory?) {
        record.willUpdate()
        record.territory = territory

        moc.unsafeSave()
    }
}

#if DEBUG
struct MoveRecordView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext

        let record = Record(context: moc)
        record.wrappedType = .apartment
        record.streetName = "Street name"
        record.city = "City"
        record.state = "State"
        record.apartmentNumber = "500"

        return NavigationView {
            MoveRecordView(record: record)
        }
        .environment(\.managedObjectContext, moc)
    }
}
#endif
