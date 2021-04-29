//
//  CollectionListHeaderCellContentView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/27/21.
//

import UIKit
import SwiftUI

class CollectionListHeaderCellContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        get { currentConfiguration }
        set {
            guard let newConfiguration = newValue as? CollectionListHeaderCellContentConfiguration
            else { return }
            apply(configuration: newConfiguration)
        }
    }
    private var currentConfiguration: CollectionListHeaderCellContentConfiguration!

    init(configuration: CollectionListHeaderCellContentConfiguration) {
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

    private func apply(configuration: CollectionListHeaderCellContentConfiguration) {
        guard currentConfiguration != configuration else { return }
        currentConfiguration = configuration

        if let title = configuration.title {
            rootView.rootView = AnyView(
                CollectionListHeader {
                    Label(title, systemImage: "")
                }
            )
        }
    }
}
