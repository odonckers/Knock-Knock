//
//  NavigationSubheader.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/14/21.
//

import SwiftUI

private struct NavigationSubheader<Content: View, Subheader: View>: View {
    var content: () -> Content
    var subheader: () -> Subheader

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            subheader()
                .padding()
                .background(
                    VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                        .edgesIgnoringSafeArea([.leading, .trailing])
                )

            Divider()
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.bottom, 0)

            content()
        }
    }
}

extension View {
    @ViewBuilder public func navigationSubheader<Subheader: View>(
        @ViewBuilder _ subheader: @escaping () -> Subheader
    ) -> some View {
        NavigationSubheader(
            content: { self },
            subheader: subheader
        )
    }
}

#if DEBUG
struct NavigationSubheader_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
            .navigationSubheader {
                Text("Hello, World!")
            }
    }
}
#endif
