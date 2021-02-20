//
//  SetSegmentedControlAppearance.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

public func setSegmentedControlAppearance(selectedTintColor: UIColor? = nil, selectedForegroundColor: UIColor? = nil) {
    UISegmentedControl.appearance().selectedSegmentTintColor = selectedTintColor
    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
}
