//
//  RecordCellContentConfiguration.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

struct RecordCellContentConfiguration: UIContentConfiguration, Hashable {
    var tagText: String?
    var tagColor: UIColor?
    var title: String?
    var subtitle: String?

    var topInset: CGFloat?
    var leftInset: CGFloat?
    var bottomInset: CGFloat?
    var rightInset: CGFloat?

    var tagBackgroundColor: UIColor?
    var tagForegroundColor: UIColor?
    var titleColor: UIColor?
    var subtitleColor: UIColor?

    func makeContentView() -> UIView & UIContentView {
        RecordCellContentView(configuration: self)
    }

    func updated(
        for state: UIConfigurationState
    ) -> RecordCellContentConfiguration {
        guard let state = state as? UICellConfigurationState
        else { return self }

        var updatedConfiguration = self
        if state.isSelected {
            updatedConfiguration.tagBackgroundColor = UIColor
                .black
                .withAlphaComponent(0.1)
            updatedConfiguration.tagForegroundColor = .white

            updatedConfiguration.titleColor = .white
            updatedConfiguration.subtitleColor = UIColor
                .white
                .withAlphaComponent(0.7)
        } else {
            updatedConfiguration.tagBackgroundColor = tagColor?
                .withAlphaComponent(0.15)
            updatedConfiguration.tagForegroundColor = tagColor

            updatedConfiguration.titleColor = .label
            updatedConfiguration.subtitleColor = .secondaryLabel
        }

        return updatedConfiguration
    }
}
