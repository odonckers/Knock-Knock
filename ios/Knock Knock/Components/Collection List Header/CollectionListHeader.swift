//
//  CollectionListHeader.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/27/21.
//

import SwiftUI

struct CollectionListHeader<Title, Icon>: View where Title: View, Icon: View {
    let label: Label<Title, Icon>

    init(@ViewBuilder label: @escaping () -> Label<Title, Icon>) {
        self.label = label()
    }

    var body: some View {
        HStack(alignment: .bottom) {
            label
                .font(.title2.bold())
            Spacer()
        }
        .padding([.top], 50)
        .padding([.horizontal, .bottom])
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
