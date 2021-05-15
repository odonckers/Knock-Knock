//
//  RecordCollectionViewListCellContentConfiguration.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

struct RecordCollectionViewListCellContentConfiguration: UIContentConfiguration, Hashable {
    var record: Record?

    var isSelected: Bool = false
    var isInset: Bool = false

    func makeContentView() -> UIView & UIContentView {
        RecordCollectionViewListCellContentView(configuration: self)
    }

    func updated(
        for state: UIConfigurationState
    ) -> RecordCollectionViewListCellContentConfiguration {
        guard let state = state as? UICellConfigurationState
        else { return self }

        var updatedConfiguration = self
        updatedConfiguration.record = record
        updatedConfiguration.isSelected = state.isSelected

        return updatedConfiguration
    }
}
