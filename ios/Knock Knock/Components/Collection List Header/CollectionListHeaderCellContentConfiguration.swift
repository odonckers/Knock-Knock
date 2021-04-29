//
//  CollectionListHeaderCellContentConfiguration.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/27/21.
//

import UIKit

struct CollectionListHeaderCellContentConfiguration: UIContentConfiguration, Hashable {
    var title: String?
    var foregroundColor: UIColor?

    func makeContentView() -> UIView & UIContentView {
        CollectionListHeaderCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        self
//        guard let state = state as? UICellConfigurationState
//        else { return self }

//        var updatedConfiguration = self
//        updatedConfiguration.record = record
//        updatedConfiguration.isSelected = state.isSelected

//        return updatedConfiguration
    }
}
