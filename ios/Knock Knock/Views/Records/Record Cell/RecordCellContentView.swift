//
//  RecordCellContentView.swift
//  Knock Knock
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
            apply(configuration: newConfiguration)
        }
    }
    private var currentConfiguration: RecordCellContentConfiguration!

    private var tagView = TagView()
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
        addSubview(tagView)

        tagView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagView
                .leadingAnchor
                .constraint(
                    equalTo: layoutMarginsGuide.leadingAnchor,
                    constant: currentConfiguration?.leftInset ?? 0
                ),
            tagView.widthAnchor.constraint(equalToConstant: 65),
            tagView
                .centerYAnchor
                .constraint(equalTo: layoutMarginsGuide.centerYAnchor),
        ])
    }

    private func setupTextStack() {
        titleLabel.font =  UIFont
            .preferredFont(forTextStyle: .body)
            .bold()
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .fill

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        addSubview(textStack)

        textStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textStack
                .leadingAnchor
                .constraint(equalTo: tagView.trailingAnchor, constant: 20),
            textStack
                .trailingAnchor
                .constraint(
                    equalTo: layoutMarginsGuide.trailingAnchor,
                    constant: currentConfiguration?.rightInset ?? 0
                ),
            textStack
                .topAnchor
                .constraint(
                    equalTo: layoutMarginsGuide.topAnchor,
                    constant: (currentConfiguration?.topInset ?? 0) + 5
                ),
            textStack
                .bottomAnchor
                .constraint(
                    equalTo: layoutMarginsGuide.bottomAnchor,
                    constant: (currentConfiguration?.bottomInset ?? 0) - 5
                ),
        ])
    }

    private func apply(configuration: RecordCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        tagView.text = configuration.tagText
        tagView.backgroundColor = configuration.tagBackgroundColor
        tagView.foregroundColor = configuration.tagForegroundColor

        titleLabel.text = configuration.title
        titleLabel.textColor = configuration.titleColor

        if let subtitle = configuration.subtitle, subtitle != "" {
            subtitleLabel.isHidden = false
            subtitleLabel.text = subtitle
            subtitleLabel.textColor = configuration.subtitleColor
        } else {
            subtitleLabel.isHidden = true
        }

        if let inset = configuration.topInset { layoutMargins.top = inset }
        if let inset = configuration.leftInset { layoutMargins.left = inset }
        if let inset = configuration.bottomInset {
            layoutMargins.bottom = inset
        }
        if let inset = configuration.rightInset { layoutMargins.right = inset }
    }
}
