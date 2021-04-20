//
//  Tag.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import UIKit
import SwiftUI

struct Tag: View {
    var text: String
    var backgroundColor: Color

    var body: some View {
        Text(text)
            .font(.subheadline)
            .bold()
            .padding([.vertical], 5)
            .padding(.horizontal, 10)
            .frame(minWidth: 65)
            .background(
                backgroundColor.opacity(0.15)
            )
            .cornerRadius(6.0)
    }
}

#if DEBUG
struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag(text: "ST", backgroundColor: .blue)
            .foregroundColor(.blue)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
