//
//  RecordCellContentView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

class RecordCellContentView: UIView, UIContentView {
    private var currentConfiguration: RecordCellContentConfiguration!
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? RecordCellContentConfiguration
            else { return }

            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }

    lazy var tagLabel: UILabel = {
        let tagLabel = UILabel()
        tagLabel.font = .boldSystemFont(ofSize: 16)
        tagLabel.textAlignment = .center
        return tagLabel
    }()
    var titleLabel = UILabel()
    lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 16)
        return subtitleLabel
    }()

    init(configuration: RecordCellContentConfiguration) {
        super.init(frame: .zero)

        setupAllViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAllViews() {
        let labelsStackView = UIStackView()
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .fill
//        labelsStackView.distribution = .equalCentering

        addSubview(tagLabel)
        addSubview(labelsStackView)

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagLabel.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            ),
            tagLabel.heightAnchor.constraint(equalToConstant: 25),
            tagLabel.widthAnchor.constraint(equalToConstant: 50),
            tagLabel.centerYAnchor.constraint(
                equalTo: layoutMarginsGuide.centerYAnchor
            ),

            labelsStackView.leadingAnchor.constraint(
                equalTo: tagLabel.trailingAnchor,
                constant: 10
            ),
            labelsStackView.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),
            labelsStackView.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor,
                constant: 5
            ),
            labelsStackView.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor,
                constant: -5
            ),
        ])

        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
    }

    private func apply(configuration: RecordCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        tagLabel.backgroundColor = configuration.tagBackgroundColor
        tagLabel.text = configuration.tagText
        tagLabel.textColor = configuration.tagForegroundColor

        titleLabel.text = configuration.title
        titleLabel.font = configuration.titleFont
        titleLabel.textColor = configuration.titleColor

        if let subtitle = configuration.subtitle, subtitle != "" {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = configuration.subtitleColor
        } else {
            subtitleLabel.isHidden = true
        }
    }
}
