//
//  RecordCellContentView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import UIKit
import SwiftUI

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

    init(configuration: RecordCellContentConfiguration) {
        super.init(frame: .zero)

        setupAllViews()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var rootView = UIHostingController(
        rootView: AnyView(EmptyView())
    )

    private func setupAllViews() {
        addSubview(rootView.view)

        rootView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rootView.view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            rootView.view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            rootView.view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }

    private func apply(configuration: RecordCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        if let record = configuration.record {
            rootView.rootView = AnyView(
                RecordCellView(
                    record: record,
                    isSelected: configuration.isSelected
                )
                .padding(.vertical, configuration.isInset ? 10 : 5)
                .padding(.horizontal, configuration.isInset ? 10 : 0)
            )

            rootView.view.backgroundColor = .clear
        }
    }
}
