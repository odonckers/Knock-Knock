//
//  CollectionListHeaderCell.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/29/21.
//

import UIKit

class CollectionListHeaderCell: UICollectionViewListCell {
    var systemImage: String?
    var title: String?
    var foregroundColor: UIColor = .label

    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = CollectionListHeaderCellContentConfiguration()
            .updated(for: state)

        config.systemImage = systemImage
        config.title = title
        config.foregroundColor = foregroundColor

        contentConfiguration = config
    }
}
