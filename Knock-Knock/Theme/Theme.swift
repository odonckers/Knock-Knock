//
//  Theme.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/28/21.
//

import Combine
import UIKit

class Theme: ObservableObject {
    init() {
        configureSegmentedControl()
    }

    private func configureSegmentedControl() {
        UISegmentedControl.appearance().selectedSegmentTintColor = .accentColor
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
    }
}
