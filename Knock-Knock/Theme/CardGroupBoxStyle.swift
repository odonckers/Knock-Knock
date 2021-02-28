//
//  CardGroupBoxStyle.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct CardGroupBoxStyle: GroupBoxStyle {
    @Environment(\.colorScheme)
    private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            VStack(alignment: .leading) {
                configuration.label
                    .font(.headline)
                    .padding(.bottom, 4)
                configuration.content
                Spacer()
            }
            Spacer()
        }
        .padding()
        .background(Color("CardBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct CardGroupBox_Previews: PreviewProvider {
    static var previews: some View {
        GroupBox(label: Label("Label", systemImage: "checkmark.circle.fill")) {
            Text("Content")
        }
        .groupBoxStyle(CardGroupBoxStyle())
        .padding()
        .background(Color.gray)
        .previewLayout(.fixed(width: 414, height: 216))
    }
}
