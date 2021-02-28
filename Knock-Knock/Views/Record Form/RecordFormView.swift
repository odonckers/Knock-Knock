//
//  RecordFormView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Introspect
import SwiftUI

struct RecordFormView: View {
    init(record: Record? = nil, territory: Territory? = nil) {
        viewModel = RecordFormViewModel(record: record, territory: territory)
    }

    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject private var viewModel: RecordFormViewModel

    // MARK: - Form

    @ViewBuilder private var form: some View {
        Form {
            Section { typePicker.formLabel("Type") }

            if viewModel.selectedTypeIndex == 1 {
                Section(header: Text("Apartment Options")) {
                    TextField("Required", text: $viewModel.apartmentNumber)
                        .formLabel("Number")
                }
            }

            Section(header: Text("Street Info")) {
                streetNameField
                TextField("Optional", text: $viewModel.city).formLabel("City")
                TextField("Optional", text: $viewModel.state).formLabel("State")
                Button(action: viewModel.useCurrentLocation) {
                    Text("Use Current Location")
                }
            }
        }
        .onAppear { viewModel.location.request() }
        .onDisappear { viewModel.location.stopUpdatingPlacement() }
    }

    // MARK: - Type Picker

    private var typeOptions = ["Street", "Apartment"]

    @ViewBuilder private var typePicker: some View {
        Picker("Type", selection: $viewModel.selectedTypeIndex.animation()) {
            ForEach(0 ..< typeOptions.count) { Text(typeOptions[$0]) }
        }
        .pickerStyle(SegmentedPickerStyle())
        .labelsHidden()
    }

    // MARK: - Street Name Field

    @State private var wasFirstResponder = false

    @ViewBuilder private var streetNameField: some View {
        TextField("Required", text: $viewModel.streetName)
            .introspectTextField {
                if !wasFirstResponder {
                    $0.becomeFirstResponder()
                    wasFirstResponder = true
                }
            }
            .formLabel("Name")
    }

    // MARK: - Save Button

    @Environment(\.managedObjectContext)
    private var viewContext

    @ViewBuilder private var saveButton: some View {
        Button(
            action: {
                withAnimation {
                    viewModel.save(viewContext: viewContext)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        ) {
            Text("Save")
        }
        .disabled(!viewModel.canSave)
    }

    // MARK: - Cancel Button

    @ViewBuilder private var cancelButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }) {
            Text("Cancel")
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            form
                .navigationTitle(viewModel.title)
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
        .introspectViewController { $0.isModalInPresentation = true }
    }
}

#if DEBUG
struct RecordFormView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let record = Record(context: viewContext)
        record.setType(.apartment)
        record.streetName = "Street name"
        record.city = "City"
        record.state = "State"
        record.apartmentNumber = "500"

        return Group {
            RecordFormView().previewDisplayName("New Form Preview")
            RecordFormView(record: record)
                .previewDisplayName("Edit Form Preview")
        }
        .onAppear {
            setSegmentedControlAppearance(
                selectedTintColor: .accentColor,
                selectedForegroundColor: .white
            )
        }
    }
}
#endif
