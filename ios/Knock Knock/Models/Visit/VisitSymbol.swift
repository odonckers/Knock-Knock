//
//  VisitSymbol.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

@objc public enum VisitSymbol: Int16, CaseIterable {
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

    public var text: String {
        switch self {
        case .notAtHome: return "Not at Home"
        case .busy: return "Busy"
        case .callAgain: return "Call Again"
        case .notInterested: return "Not Interested"
        case .other: return "Other"
        }
    }

    public var systemImage: String {
        switch self {
        case .notAtHome: return "xmark.octagon"
        case .busy: return "alarm"
        case .callAgain: return "checkmark.circle"
        case .notInterested: return "minus.circle"
        case .other: return "o.circle"
        }
    }
}
