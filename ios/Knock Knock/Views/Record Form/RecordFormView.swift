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
    @Environment(\.managedObjectContext)
    private var moc

    @Environment(\.uiNavigationController)
    private var navigationController

    @EnvironmentObject private var viewModel: RecordFormViewModel

    @FetchRequest(entity: Territory.entity(), sortDescriptors: [])
    private var territories: FetchedResults<Territory>

    private var typeOptions = ["Street", "Apartment"]

    var body: some View {
        Form {
            Section {
                Picker("Territory", selection: $viewModel.territory) {
                    Text("None")
                        .tag(nil as Territory?)

                    ForEach(territories, id: \.self) { territory in
                        Text(territory.wrappedName)
                            .tag(territory as Territory?)
                    }
                }
            }

            Section {
                Picker(
                    "general.type",
                    selection: $viewModel.selectedTypeIndex.animation()
                ) {
                    ForEach(0..<typeOptions.count) { i in
                        Text(typeOptions[i])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .formLabel("general.type")
            }

            if viewModel.selectedTypeIndex == 1 {
                Section(header: Text("recordForm.header.apartment")) {
                    TextField(
                        "recordForm.field.apartmentNumber.required",
                        text: $viewModel.apartmentNumber
                    )
                }
            }

            Section(header: Text("recordForm.header.street")) {
                TextField(
                    "recordForm.field.streetName.required",
                    text: $viewModel.streetName
                )
                TextField("recordForm.field.city", text: $viewModel.city)
                TextField("recordForm.field.state", text: $viewModel.state)
            }

            Section(header: Text("recordForm.header.geolocation")) {
                useCurrentLocationButton
            }
        }
        .navigationTitle(
            viewModel.record?.streetName != nil
                ? "recordForm.title.edit"
                : "recordForm.title.new"
        )
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    navigationController?.dismiss(animated: true)
                }) {
                    Text("general.cancel")
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    if self.viewModel.canSave {
                        self.viewModel.save(in: self.moc)
                        self.navigationController?.dismiss(animated: true)
                    }
                }) {
                    Text("general.save")
                }
            }
        }
        .onAppear {
            navigationController?.navigationBar.prefersLargeTitles = true
//            navigationController?.navigationItem.largeTitleDisplayMode = .always
        }
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
                self.viewModel.streetName = streetName
            }
            if let city = placemark?.locality { self.viewModel.city = city }
            if let state = placemark?.administrativeArea {
                self.viewModel.state = state
            }
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
                .environmentObject(RecordFormViewModel())
                .previewDisplayName("New Form Preview")

            RecordFormView()
                .environmentObject(RecordFormViewModel(record: record))
                .previewDisplayName("Edit Form Preview")
        }
        .environment(\.managedObjectContext, moc)
    }
}
#endif
