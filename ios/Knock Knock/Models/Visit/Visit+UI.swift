//
//  Visit+UI.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension Visit {
    public var symbolColor: Color {
        switch wrappedSymbol {
        case .notAtHome: return .visitSymbolNotAtHome
        case .busy: return .visitSymbolBusy
        case .callAgain: return .visitSymbolCallAgain
        case .notInterested: return .visitSymbolNotInterested
        case .other: return .visitSymbolOther
        }
    }
}
