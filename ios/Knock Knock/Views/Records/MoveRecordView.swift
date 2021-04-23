//
//  MoveRecordView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/19/21.
//

import SwiftUI

struct MoveRecordView: View {
    var record: Record

    @Environment(\.managedObjectContext) private var moc
    @Environment(\.uiNavigationController) private var navigationController

    @FetchRequest(entity: Territory.entity(), sortDescriptors: [])
    private var territories: FetchedResults<Territory>

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            RecordRow(record: record)
                .padding()
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                        .edgesIgnoringSafeArea([.leading, .trailing])
                )

            Divider()

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
                        save(selected: nil)
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
                            save(selected: territory)
                            navigationController?.dismiss(animated: true)
                        }) {
                            Label(territory.wrappedName, systemImage: "folder")
                        }
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
        .onAppear {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
}

extension MoveRecordView {
    private func save(selected: Territory?) {
        record.willUpdate()
        record.territory = selected

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
