//
//  SetSegmentedControlAppearance.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

public func setSegmentedControlAppearance() {
    UISegmentedControl.appearance().selectedSegmentTintColor = .accentColor
    UISegmentedControl.appearance().setTitleTextAttributes(
        [.foregroundColor: UIColor.white],
        for: .selected
    )
}
