//
//  Attempt+SwiftUI.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension Attempt {
    public var symbolColor: Color {
        switch wrappedSymbol {
        case .notAtHome:
            return Color("NotAtHomeColor")
        case .busy:
            return Color("BusyColor")
        case .callAgain:
            return Color("CallAgainColor")
        case .notInterested:
            return Color("NotInterestedColor")
        case .other:
            return Color("OtherColor")
        }
    }
}
