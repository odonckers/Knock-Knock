//
//  RecordFormView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Introspect
import SwiftUI

struct RecordFormView: View {
    var record: Record? = nil
    var territory: Territory? = nil

    init(record: Record? = nil, territory: Territory? = nil) {
        self.record = record
        self.territory = territory

        if let record = record {
            selectedTypeIndex = Int(record.wrappedType.rawValue)

            if let streetName = record.streetName {
                self.streetName = streetName
            }
            if let city = record.city { self.city = city }
            if let state = record.state { self.state = state }
            if let apartmentNumber = record.apartmentNumber {
                self.apartmentNumber = apartmentNumber
            }
        }
    }

    @Environment(\.managedObjectContext)
    private var viewContext

    @Environment(\.presentationMode)
    private var presentationMode

    @State var selectedTypeIndex = 0
    @State var streetName = ""
    @State var city = ""
    @State var state = ""
    @State var apartmentNumber = ""

    @State var location = LocationManager()

    var title: String {
        record?.streetName != nil ? "Edit Record" : "New Record"
    }

    var body: some View {
        NavigationView {
            Form {
                typePicker

                if selectedTypeIndex == 1 {
                    Section(header: Text("Apartment Options")) {
                        TextField(
                            "Apartment Number (Required)",
                            text: $apartmentNumber
                        )
                    }
                }

                Section(header: Text("Street Info")) {
                    streetNameField
                    TextField("City", text: $city)
                    TextField("State", text: $state)
                }

                Section(header: Text("Geolocation")) {
                    Button(action: useCurrentLocation) {
                        Text("Use Current Location")
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
        .onAppear { location.request() }
        .onDisappear { location.stopUpdatingPlacement() }
    }

    func useCurrentLocation() {
        location.whenAuthorized { placemark in
            if let streetName = placemark?.thoroughfare {
                self.streetName = streetName
            }
            if let city = placemark?.locality { self.city = city }
            if let state = placemark?.administrativeArea { self.state = state }
        }
    }

    // MARK: - Save Button

    var isApartment: Bool { selectedTypeIndex == 1 }
    var canSave: Bool {
        if isApartment {
            return streetName != "" && apartmentNumber != ""
        } else {
            return streetName != ""
        }
    }

    @ViewBuilder private var saveButton: some View {
        Button(action: { withAnimation { save() } }) {
            Text("Save")
        }
        .disabled(!canSave)
    }

    func save() {
        var toSave: Record
        if let record = record {
            toSave = record
            toSave.willUpdate()
        } else {
            toSave = Record(context: viewContext)
            toSave.willCreate()
        }

        toSave.wrappedType = isApartment ? .apartment : .street
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.territory = territory

        viewContext.unsafeSave()
        presentationMode.wrappedValue.dismiss()
    }

    // MARK: - Type Picker

    private var typeOptions = ["Street", "Apartment"]

    @ViewBuilder private var typePicker: some View {
        Picker("Type", selection: $selectedTypeIndex.animation()) {
            ForEach(0 ..< typeOptions.count) { Text(typeOptions[$0]) }
        }
        .pickerStyle(SegmentedPickerStyle())
        .formLabel("Type")
    }

    // MARK: - Street Name Field

    @State private var wasFirstResponder = false

    @ViewBuilder private var streetNameField: some View {
        TextField("Street Name (Required)", text: $streetName)
            .introspectTextField { textField in
                if !wasFirstResponder {
                    textField.becomeFirstResponder()
                    wasFirstResponder.toggle()
                }
            }
    }
}

#if DEBUG
struct RecordFormView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let record = Record(context: viewContext)
        record.wrappedType = .apartment
        record.streetName = "Street name"
        record.city = "City"
        record.state = "State"
        record.apartmentNumber = "500"

        return Group {
            RecordFormView().previewDisplayName("New Form Preview")
            RecordFormView(record: record)
                .previewDisplayName("Edit Form Preview")
        }
        .environmentObject(Theme())
    }
}
#endif
