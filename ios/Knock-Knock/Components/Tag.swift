//
//  Tag.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import UIKit
import SwiftUI

class UITag: UIView {
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
        label.font = UIFont.preferredFont(forTextStyle: .subheadline).bold()
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

struct Tag<Content: View>: View {
    let color: Color
    let content: () -> Content

    init(color: Color = .accentColor, content: @escaping () -> Content) {
        self.color = color
        self.content = content
    }

    @Environment(\.colorScheme)
    private var colorScheme

    var body: some View {
        content()
            .font(Font.subheadline.bold())
            .padding([.top, .bottom], 5)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
            .scaledToFill()
    }
}

#if DEBUG
struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag { Text("GET") }
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
