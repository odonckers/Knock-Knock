//
//  DoorFormView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import SwiftUI

struct DoorFormView: HostedControllerView {
    var dismiss: (() -> Void)?

    var door: Door? = nil
    var record: Record? = nil

    init(door: Door? = nil, record: Record? = nil) {
        self.door = door
        self.record = record
    }

    @Environment(\.presentationMode)
    private var presentationMode

    private var persistenceController: PersistenceController = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistenceController
    }()

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
        NavigationView {
            Form {
                Section {
                    TextField("Number", text: $number)
                    TextField("Unit", text: $unit)
                }

                Section(header: Text("First Visit")) {
                    DatePicker("Date", selection: $date)
                    Picker(
                        symbols[selectedSymbol] ?? "",
                        selection: $selectedSymbol.animation()
                    ) {
                        ForEach(VisitSymbol.allCases, id: \.self) {
                            Text(symbols[$0] ?? "")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .formLabel("Symbol", color: .black)

                    if selectedSymbol != .notAtHome {
                        Picker(
                            persons[selectedPerson] ?? "",
                            selection: $selectedPerson.animation(.none)
                        ) {
                            ForEach(VisitPerson.allCases, id: \.self) {
                                Text(persons[$0] ?? "")
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
            .navigationTitle("Hello, World!")
        }
    }

    private func closePresentation() {
        if let dismiss = dismiss { dismiss() }
        else { presentationMode.wrappedValue.dismiss() }
    }
}

#if DEBUG
struct DoorFormView_Previews: PreviewProvider {
    static var previews: some View {
        DoorFormView()
    }
}
#endif
