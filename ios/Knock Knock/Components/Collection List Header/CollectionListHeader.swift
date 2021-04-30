//
//  CollectionListHeader.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/27/21.
//

import SwiftUI

struct CollectionListHeader<Content>: View where Content: View {
    let content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .bottom) {
            content
                .font(.title2.bold())
                .imageScale(.small)
            Spacer()
        }
        .padding(.top, 30)
        .padding(.bottom, 5)
        .padding(.horizontal)
    }
}

#if DEBUG
struct CollectionListHeader_Previews: PreviewProvider {
    static var previews: some View {
        CollectionListHeader {
            Label("Hello world", systemImage: "plus")
        }
        .frame(width: 400)
        .previewLayout(.sizeThatFits)
    }
}
#endif
