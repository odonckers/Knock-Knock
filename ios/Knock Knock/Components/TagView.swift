//
//  TagView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import UIKit
import SwiftUI

class TagView: UIView {
    var text: String? {
        didSet { label.text = text }
    }
    var foregroundColor: UIColor? {
        didSet { label.textColor = foregroundColor }
    }

    init() {
        super.init(frame: .zero)

        layer.cornerRadius = 6
        clipsToBounds = true

        setupLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var label = UILabel()

    private func setupLabel() {
        label.font = UIFont
            .preferredFont(forTextStyle: .subheadline)
            .bold()
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center

        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}
