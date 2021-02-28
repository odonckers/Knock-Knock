//
//  TerritoryFormViewModel.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Combine
import Foundation

class TerritoryFormViewModel: ObservableObject {
    var territory: Territory? = nil

    init(territory: Territory? = nil) {
        self.territory = territory

        if let territory = self.territory, let name = territory.name {
            self.name = name
        }
    }

    @Published var name = ""
    @Published var didInitiallyRespondKeyboard = false

    var title: String { territory != nil ? "Edit Territory" : "New Territory" }
    var canSave: Bool { name != "" }

    private let viewContext = PersistenceController.shared.container.viewContext

    func save() {
        if canSave {
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
    }

    func keyboardResponded() {
        didInitiallyRespondKeyboard = true
    }
}
