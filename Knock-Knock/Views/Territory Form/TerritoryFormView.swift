//
//  TerritoryFormView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Introspect
import SwiftUI

struct TerritoryFormView: View {
    var territory: Territory? = nil

    init(territory: Territory? = nil) {
        self.territory = territory

        if let territory = territory, let name = territory.name {
            self.name = name
        }
    }

    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.presentationMode)
    private var presentationMode

    @State private var name = ""
    @State private var wasFirstResponder = false

    private var title: String {
        territory != nil ? "Edit Territory" : "New Territory"
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info")) {
                    TextField("Name (Required)", text: $name)
                        .introspectTextField { textField in
                            if !wasFirstResponder {
                                textField.becomeFirstResponder()
                                wasFirstResponder.toggle()
                            }
                        }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(
                        action: { presentationMode.wrappedValue.dismiss() }
                    ) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) { saveButton }
            }
        }
        .introspectViewController { viewController in
            viewController.isModalInPresentation = true
        }
    }

    // MARK: - Save Button
    
    private var canSave: Bool { name != "" }

    @ViewBuilder private var saveButton: some View {
        Button(action: { save() }) {
            Text("Save")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(!canSave)
    }

    private func save() {
        if canSave {
            withAnimation {
                var toSave: Territory
                if let territory = self.territory {
                    toSave = territory
                    toSave.willUpdate()
                } else {
                    toSave = Territory(context: viewContext)
                    toSave.willCreate()
                }

                toSave.name = name
                viewContext.unsafeSave()
            }

            presentationMode.wrappedValue.dismiss()
        }
    }
}

#if DEBUG
struct TerritoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let territory = Territory(context: viewContext)
        territory.name = "D2D-77"

        return Group {
            TerritoryFormView().previewDisplayName("New Form Preview")
            TerritoryFormView(territory: territory)
                .previewDisplayName("Edit Form Preview")
        }
    }
}
#endif
