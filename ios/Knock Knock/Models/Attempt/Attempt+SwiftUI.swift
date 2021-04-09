//
//  Attempt+SwiftUI.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension Attempt {
    public var symbolColor: Color {
        switch wrappedSymbol {
        case .notAtHome: return .attemptSymbolNotAtHome
        case .busy: return .attemptSymbolBusy
        case .callAgain: return .attemptSymbolCallAgain
        case .notInterested: return .attemptSymbolNotInterested
        case .other: return .attemptSymbolOther
        }
    }
}
