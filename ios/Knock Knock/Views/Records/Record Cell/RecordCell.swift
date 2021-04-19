//
//  RecordCell.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

class RecordCell: UICollectionViewListCell {
    var record: Record?
    var isInset = false

    override func updateConfiguration(using state: UICellConfigurationState) {
        var config = RecordCellContentConfiguration()
            .updated(for: state)

        config.record = record
        config.isInset = isInset

        contentConfiguration = config
    }
}
