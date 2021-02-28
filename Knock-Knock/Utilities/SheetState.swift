//
//  SheetState.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import Foundation

class SheetState<State>: ObservableObject {
    @Published var isPresented = false
    @Published var state: State? {
        didSet { isPresented = state != nil }
    }
    @Published var arguments: Any? = nil

    func present(_ state: State, with arguments: Any? = nil) {
        self.state = state
        self.arguments = arguments
    }
}
