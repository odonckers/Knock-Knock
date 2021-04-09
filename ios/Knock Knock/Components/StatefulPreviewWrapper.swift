//
//  StatefulPreviewWrapper.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (_: Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }

    var body: some View { content($value) }
}
