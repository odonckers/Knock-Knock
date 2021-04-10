//
//  RecordFormView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct RecordFormView: HostedControllerView {
    var dismiss: (() -> Void)?

    var record: Record? = nil
    var territory: Territory? = nil

    init(record: Record? = nil, territory: Territory? = nil) {
        self.record = record
        self.territory = territory
    }

    @Environment(\.presentationMode)
    private var presentationMode

    private var persistenceController: PersistenceController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistenceController
    }()

    @State var selectedTypeIndex = 0
    @State var streetName = ""
    @State var city = ""
    @State var state = ""
    @State var apartmentNumber = ""

    var body: some View {
        NavigationView {
            Form {
                Section { typePicker }

                if selectedTypeIndex == 1 {
                    Section(header: Text("recordForm.header.apartment")) {
                        TextField(
                            "recordForm.field.apartmentNumber.required",
                            text: $apartmentNumber
                        )
                    }
                }

                Section(header: Text("recordForm.header.street")) {
                    TextField(
                        "recordForm.field.streetName.required",
                        text: $streetName
                    )
                    TextField("recordForm.field.city", text: $city)
                    TextField("recordForm.field.state", text: $state)
                }

                Section(header: Text("recordForm.header.geolocation")) {
                    useCurrentLocationButton
                }
            }
            .navigationTitle(
                record?.streetName != nil ?
                    "recordForm.title.edit" :
                    "recordForm.title.new"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { cancelButton }
                ToolbarItem(placement: .confirmationAction) { saveButton }
            }
        }
        .onAppear {
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
    }

    private func closePresentation() {
        if let dismiss = dismiss { dismiss() }
        else { presentationMode.wrappedValue.dismiss() }
    }

    // MARK: - Type Picker

    private var typeOptions = ["Street", "Apartment"]

    @ViewBuilder private var typePicker: some View {
        Picker("general.type", selection: $selectedTypeIndex.animation()) {
            ForEach(0 ..< typeOptions.count) { Text(typeOptions[$0]) }
        }
        .pickerStyle(SegmentedPickerStyle())
        .formLabel("general.type")
    }

    // MARK: - Use Current Location Button

    @State private var location = LocationManager()

    @ViewBuilder private var useCurrentLocationButton: some View {
        Button(action: useCurrentLocation) {
            Text("recordForm.button.currentLocation")
        }
        .onAppear { location.request() }
        .onDisappear { location.stopUpdatingPlacement() }
    }

    private func useCurrentLocation() {
        location.whenAuthorized { placemark in
            if let streetName = placemark?.thoroughfare {
                self.streetName = streetName
            }
            if let city = placemark?.locality { self.city = city }
            if let state = placemark?.administrativeArea { self.state = state }
        }
    }

    // MARK: - Cancel Button

    @ViewBuilder private var cancelButton: some View {
        Button(action: closePresentation) {
            Text("general.cancel")
        }
    }

    // MARK: - Save Button

    private var isApartment: Bool { selectedTypeIndex == 1 }
    private var canSave: Bool {
        if isApartment {
            return streetName != "" && apartmentNumber != ""
        } else {
            return streetName != ""
        }
    }

    @ViewBuilder private var saveButton: some View {
        Button(action: save) { Text("general.save") }
            .disabled(!canSave)
    }

    private func save() {
        var toSave: Record
        if let record = record {
            toSave = record
            toSave.willUpdate()
        } else {
            toSave = Record(
                context: persistenceController.container.viewContext
            )
            toSave.willCreate()
        }

        toSave.wrappedType = isApartment ? .apartment : .street
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.territory = territory

        persistenceController.container.viewContext.unsafeSave()
        closePresentation()
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
            RecordFormView()
                .previewDisplayName("New Form Preview")
            RecordFormView(record: record)
                .previewDisplayName("Edit Form Preview")
        }
    }
}
#endif
