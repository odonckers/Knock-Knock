//
//  ScaleButtonStyle.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/23/21.
//

import SwiftUI

struct ScaleButtonStyle: ButtonStyle {


    func makeBody(configuration: Configuration) -> some View {
        configuration.label.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#if DEBUG
struct ScaleButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}) {
            Label("Button", systemImage: "plus")
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
#endif
