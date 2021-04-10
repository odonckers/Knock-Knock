//
//  RecordFormView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData
import Combine
import SwiftUI

class RecordFormViewController: UIHostingController<AnyView> {
    private let viewContext: NSManagedObjectContext
    private let viewModel: RecordFormViewModel

    init(record: Record? = nil, territory: Territory? = nil) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        viewContext = appDelegate.persistenceController.container.viewContext

        viewModel = RecordFormViewModel(record: record, territory: territory)

        let recordFormView = RecordFormView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(viewModel)

        super.init(rootView: AnyView(recordFormView))
        configureNavigationBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func cancel(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension RecordFormViewController {
    private func configureNavigationBar() {
        title = viewModel.record?.streetName != nil
            ? "Edit Street"
            : "New Street"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel(sender:))
        )

        let confirmButton = UIBarButtonItem(
            title: "Save",
            primaryAction: UIAction { [weak self] action in
                guard let self = self else { return }
                if self.viewModel.canSave {
                    self.viewModel.save(viewContext: self.viewContext)
                    self.dismiss(animated: true)
                }
            }
        )
        confirmButton.style = .done
        navigationItem.rightBarButtonItem = confirmButton
    }
}

private struct RecordFormView: View {
    @Environment(\.managedObjectContext)
    private var viewContext

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
        .navigationBarTitleDisplayMode(.large)
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
        let viewContext = PersistenceController.preview.container.viewContext

        let record = Record(context: viewContext)
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
        .environment(\.managedObjectContext, viewContext)
    }
}
#endif
