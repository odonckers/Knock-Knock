//
//  CollectionListHeaderCellContentConfiguration.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/27/21.
//

import UIKit

struct CollectionListHeaderCellContentConfiguration: UIContentConfiguration, Hashable {
    var systemImage: String?
    var title: String?
    var foregroundColor: UIColor?

    func makeContentView() -> UIView & UIContentView {
        CollectionListHeaderCellContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        var updatedConfiguration = self
        updatedConfiguration.systemImage = systemImage
        updatedConfiguration.title = title
        updatedConfiguration.foregroundColor = foregroundColor

        return updatedConfiguration
    }
}
