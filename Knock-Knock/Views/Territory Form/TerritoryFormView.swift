//
//  TerritoryFormView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Introspect
import SwiftUI

struct TerritoryFormView: View {
    init(territory: Territory? = nil) {
        viewModel = TerritoryFormViewModel(territory: territory)
    }

    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject private var viewModel: TerritoryFormViewModel

    // MARK: - Form

    @ViewBuilder private var form: some View {
        Form {
            Section(header: Text("Info")) {
                TextField("Required", text: $viewModel.name)
                    .introspectTextField {
                        if !viewModel.didInitiallyRespondKeyboard {
                            $0.becomeFirstResponder()
                            viewModel.keyboardResponded()
                        }
                    }
                    .formLabel("Name")
            }
        }
    }

    // MARK: - Cancel Button

    @ViewBuilder private var cancelButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Text("Cancel")
        }
    }

    // MARK: - Save Button

    @ViewBuilder private var saveButton: some View {
        Button(
            action: {
                withAnimation { viewModel.save() }
                presentationMode.wrappedValue.dismiss()
            }
        ) {
            Text("Save")
        }
        .keyboardShortcut(.defaultAction)
        .disabled(!viewModel.canSave)
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            form
                .navigationTitle(viewModel.title)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { cancelButton }
                    ToolbarItem(placement: .confirmationAction) { saveButton }
                }
        }
        .introspectViewController {
            $0.isModalInPresentation = true
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
