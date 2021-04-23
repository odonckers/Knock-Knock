//
//  VisualEffectView.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/19/21.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    var tintColor: Color?

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
        if let tintColor = tintColor { uiView.backgroundColor = UIColor(tintColor) }
    }
}
