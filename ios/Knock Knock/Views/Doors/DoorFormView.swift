//
//  DoorFormView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import SwiftUI

struct DoorFormView: View {
    var door: Door? = nil
    var record: Record

    init(door: Door? = nil, record: Record) {
        self.door = door
        self.record = record
    }

    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.uiNavigationController) private var navigationController

    @State private var number = ""
    @State private var unit = ""
    @State private var date = Date()

    private var symbols: [VisitSymbol: String] = [
        .notAtHome: "Not-at-Home",
        .busy: "Busy",
        .callAgain: "Call Again",
        .notInterested: "Not Interested",
        .other: "Other",
    ]
    @State private var selectedSymbol: VisitSymbol = .notAtHome

    private var persons: [VisitPerson: String] = [
        .nobody: "Nobody",
        .man: "Man",
        .woman: "Woman",
        .child: "Child",
    ]
    @State private var selectedPerson: VisitPerson = .nobody

    @State private var notes = ""

    var body: some View {
        Form {
            Section {
                TextField("Number", text: $number)
                TextField("Unit", text: $unit)
            }

            if door == nil {
                Section(header: Text("First Visit")) {
                    DatePicker("Date", selection: $date)
                    Picker(
                        symbols[selectedSymbol] ?? "",
                        selection: $selectedSymbol.animation()
                    ) {
                        ForEach(VisitSymbol.allCases, id: \.self) { i in
                            Text(symbols[i] ?? "")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .formLabel("Symbol", color: .black)

                    if selectedSymbol != .notAtHome {
                        Picker(
                            persons[selectedPerson] ?? "",
                            selection: $selectedPerson.animation(.none)
                        ) {
                            ForEach(VisitPerson.allCases, id: \.self) { i in
                                Text(persons[i] ?? "")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .formLabel("Person", color: .black)
                    }
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
        }
        .navigationTitle(door?.wrappedNumber != nil ? "Edit Door" : "New Door")
        .navigationBarTitleDisplayMode(.inline)
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
            }
        }
        .onAppear {
            if let door = door {
                if let number = door.number { self.number = number }
                if let unit = door.unit { self.unit = unit }
            }
        }
    }
}

extension DoorFormView {
    private func save() {
        var toSave: Door
        if let door = door {
            toSave = door
            toSave.willUpdate()
        } else {
            toSave = Door(context: moc)
            toSave.willCreate()

            let firstVisit = Visit(context: moc)
            firstVisit.willCreate()

            firstVisit.date = date
            firstVisit.wrappedSymbol = selectedSymbol
            firstVisit.wrappedPerson = selectedPerson
            firstVisit.notes = notes

            firstVisit.door = toSave
        }

        toSave.number = number
        toSave.unit = unit

        toSave.record = record

        moc.unsafeSave()
    }
}

#if DEBUG
struct DoorFormView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext

        let record = Record(context: moc)
        record.streetName = "Street Name"
        record.city = "City"
        record.state = "State"

        return EnvironmentUIPreviewWrapper { DoorFormView(record: record) }
    }
}
#endif
