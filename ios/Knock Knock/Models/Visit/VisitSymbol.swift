//
//  VisitSymbol.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

public enum VisitSymbol: Int16, CaseIterable {
    case notAtHome = 0
    case busy = 1
    case callAgain = 2
    case notInterested = 3
    case other = 4

    public var color: Color {
        switch self {
        case .notAtHome: return .visitSymbolNotAtHome
        case .busy: return .visitSymbolBusy
        case .callAgain: return .visitSymbolCallAgain
        case .notInterested: return .visitSymbolNotInterested
        case .other: return .visitSymbolOther
        }
    }
}
