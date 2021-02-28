//
//  FilledBackground.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

private struct FilledBackground<Content: View, Background: View>: View {
    var content: () -> Content
    var background: () -> Background

    var body: some View {
        ZStack {
            background().edgesIgnoringSafeArea(.all)
            content()
        }
    }
}

extension View {
    @ViewBuilder public func filledBackground<Content: View>(
        _ background: Content
    ) -> some View {
        FilledBackground(
            content: { self },
            background: { background.edgesIgnoringSafeArea(.all) }
        )
    }
}

struct FilledBackground_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
            .foregroundColor(.white)
            .filledBackground(Color.accentColor)
            .frame(width: 240, height: 240)
            .previewLayout(.sizeThatFits)
    }
}

