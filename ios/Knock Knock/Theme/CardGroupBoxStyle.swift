//
//  CardGroupBoxStyle.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct CardGroupBoxStyle<TrailingContent>: GroupBoxStyle where TrailingContent: View {
    let trailingContent: TrailingContent?

    init(@ViewBuilder trailingContent: () -> TrailingContent? = { nil }) {
        self.trailingContent = trailingContent()
    }

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                configuration.label
                    .font(.headline)
                    .padding()
                Spacer()
                if let trailingContent = trailingContent { trailingContent }
            }

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
        .groupBoxStyle(
            CardGroupBoxStyle(
                trailingContent: {
                    Image(systemName: "more")
                    Image(systemName: "chevron.right")
                }
            )
        )
        .padding()
        .background(Color.gray)
        .previewLayout(.fixed(width: 414, height: 216))
    }
}
#endif
