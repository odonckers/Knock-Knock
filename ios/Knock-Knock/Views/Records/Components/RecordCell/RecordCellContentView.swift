//
//  RecordCellContentView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit

class RecordCellContentView: UIView, UIContentView {
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
    private var currentConfiguration: RecordCellContentConfiguration!

    private var tagContainer = UIView()
    private var tagLabel = UILabel()

    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()

    init(configuration: RecordCellContentConfiguration) {
        super.init(frame: .zero)

        setupAllViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAllViews() {
        setupTag()
        setupTextStack()
    }

    private func setupTag() {
        tagContainer.layer.cornerRadius = 6
        tagContainer.clipsToBounds = true

        tagLabel.font = .boldSystemFont(ofSize: 16)
        tagLabel.textAlignment = .center
        tagContainer.addSubview(tagLabel)

        addSubview(tagContainer)

        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagContainer.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            ),
            tagContainer.widthAnchor.constraint(equalToConstant: 65),
            tagContainer.centerYAnchor.constraint(
                equalTo: layoutMarginsGuide.centerYAnchor
            ),

            tagLabel.leadingAnchor.constraint(
                equalTo: tagContainer.leadingAnchor
            ),
            tagLabel.trailingAnchor.constraint(
                equalTo: tagContainer.trailingAnchor
            ),
            tagLabel.topAnchor.constraint(
                equalTo: tagContainer.topAnchor,
                constant: 5
            ),
            tagLabel.bottomAnchor.constraint(
                equalTo: tagContainer.bottomAnchor,
                constant: -5
            ),
        ])
    }

    private func setupTextStack() {
        subtitleLabel.font = .systemFont(ofSize: 14)

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        addSubview(textStack)

        textStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(
                equalTo: tagLabel.trailingAnchor,
                constant: 20
            ),
            textStack.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),
            textStack.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor,
                constant: 5
            ),
            textStack.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor,
                constant: -5
            ),
        ])
    }

    private func apply(configuration: RecordCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        tagContainer.backgroundColor = configuration.tagBackgroundColor

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
