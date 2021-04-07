//
//  RecordCell.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

class RecordCell: UICollectionViewListCell {
    var record: Record?
    var contentInsets: UIEdgeInsets?

    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = RecordCellContentConfiguration()
            .updated(for: state)

        config.tagText = record?.abbreviatedType
        config.tagColor = UIColor(record?.typeColor ?? .accentColor)

        config.title = record?.wrappedStreetName

        var secondaryTexts: [String] = []
        if let city = record?.city, city != "" {
            secondaryTexts.append(city)
        }
        if let state = record?.state, state != "" {
            secondaryTexts.append(state)
        }
        config.subtitle = secondaryTexts.joined(separator: ", ")

        config.topInset = contentInsets?.top
        config.leftInset = contentInsets?.left
        config.bottomInset = contentInsets?.bottom
        config.rightInset = contentInsets?.right

        contentConfiguration = config
    }
}
