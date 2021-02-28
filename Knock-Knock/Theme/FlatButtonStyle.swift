//
//  FlatButtonStyle.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct FlatButtonStyle: ButtonStyle {
    @Environment(\.colorScheme)
    private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        let color = Color.accentColor
        let pressed = configuration.isPressed

        return configuration.label
            .font(Font.body.weight(.medium))
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 4)
            .background(
                color.opacity(
                    pressed ? 0.06 : (colorScheme == .dark ? 0.3 : 0.1)
                )
            )
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct FlatButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: { }) {
            Text("Hello World")
        }
        .buttonStyle(FlatButtonStyle())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
