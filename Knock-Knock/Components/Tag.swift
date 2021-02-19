//
//  Tag.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct Tag<Content: View>: View {
    private let color: Color
    private let pressed: Bool
    private let label: Content
    
    init(
        color: Color = .accentColor,
        pressed: Bool = false,
        label: @escaping () -> Content
    ) {
        self.color = color
        self.pressed = pressed
        self.label = label()
    }
        
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        label
            .font(Font.subheadline.bold())
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 4)
            .background(
                color.opacity(
                    colorScheme == .dark ? 0.3 : 0.1
                )
            )
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag() {
            Text("GET")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
