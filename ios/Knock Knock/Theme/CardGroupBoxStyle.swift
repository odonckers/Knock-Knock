//
//  CardGroupBoxStyle.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct CardGroupBoxStyle: GroupBoxStyle {
    var headerTintColor: Color?

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                configuration.label
                    .font(.headline)
                    .padding()
                Spacer()
            }
            .background(
                VisualEffectView(
                    effect: UIBlurEffect(style: .systemUltraThinMaterial),
                    tintColor: headerTintColor
                )
            )
            Divider()
            VStack(alignment: .leading) {
                configuration.content
                Spacer()
            }
            .padding()
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#if DEBUG
struct CardGroupBox_Previews: PreviewProvider {
    static var previews: some View {
        GroupBox(label: Label("Label", systemImage: "checkmark")) {
            Text("Content")
        }
        .groupBoxStyle(CardGroupBoxStyle(headerTintColor: .red))
        .padding()
        .background(Color.white)
        .previewLayout(.fixed(width: 414, height: 216))
    }
}
#endif
