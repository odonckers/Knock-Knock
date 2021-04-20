//
//  RecordFormView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import Combine
import SwiftUI

struct RecordFormView: View {
    var record: Record? = nil
    var territory: Territory? = nil

    init(record: Record? = nil, territory: Territory? = nil) {
        self.record = record
        self.territory = territory

        if let record = record {
            selectedTypeIndex = Int(record.wrappedType.rawValue)

            if let streetName = record.streetName { self.streetName = streetName }
            if let city = record.city { self.city = city }
            if let state = record.state { self.state = state }
            if let apartmentNumber = record.apartmentNumber {
                self.apartmentNumber = apartmentNumber
            }
        }
    }

    @Environment(\.managedObjectContext)
    private var moc

    @Environment(\.uiNavigationController)
    private var navigationController

    @State private var selectedTypeIndex = 0
    private var typeOptions = ["Street", "Apartment"]

    @State private var streetName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var apartmentNumber = ""

    private var isApartment: Bool { selectedTypeIndex == 1 }
    private var canSave: Bool {
        if isApartment { return streetName != "" && apartmentNumber != "" }
        else { return streetName != "" }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if let record = record {
                RecordCellView(record: record)
                    .padding()
                    .background(
                        VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                            .edgesIgnoringSafeArea([.leading, .trailing])
                    )

                Divider()
            }

            Form {
                Section {
                    Picker("type", selection: $selectedTypeIndex.animation()) {
                        ForEach(0..<typeOptions.count) { i in
                            Text(typeOptions[i])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .formLabel("type")
                }

                if isApartment {
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
        }
        .navigationTitle(
            record?.streetName != nil ? "recordForm.title.edit" : "recordForm.title.new"
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: { navigationController?.dismiss(animated: true) }) {
                    Text("cancel")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    save()
                    navigationController?.dismiss(animated: true)
                }) {
                    Text("save")
                }
                .disabled(!canSave)
            }
        }
        .onAppear {
            if record != nil {
                navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
    }

    private func save() {
        var toSave: Record
        if let record = record {
            toSave = record
            toSave.willUpdate()
        } else {
            toSave = Record(context: moc)
            toSave.willCreate()
        }

        toSave.wrappedType = isApartment ? .apartment : .street
        toSave.apartmentNumber = isApartment ? apartmentNumber : nil
        toSave.streetName = streetName
        toSave.city = city
        toSave.state = state
        toSave.territory = territory

        moc.unsafeSave()
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
            if let streetName = placemark?.thoroughfare { self.streetName = streetName }
            if let city = placemark?.locality { self.city = city }
            if let state = placemark?.administrativeArea { self.state = state }
        }
    }
}

#if DEBUG
struct RecordFormView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext

        let record = Record(context: moc)
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
        .environment(\.managedObjectContext, moc)
    }
}
#endif
