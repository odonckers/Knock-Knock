//
//  Record+SwiftUI.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension Record {
    public var abbreviatedType: String {
        switch wrappedType {
        case .street: return "ST"
        case .apartment: return "APT"
        }
    }

    public var typeColor: Color {
        switch wrappedType {
        case .street: return .recordTypeStreet
        case .apartment: return .recordTypeApartment
        }
    }
}
