//
//  ContainerView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

protocol ContainerView: View {
    associatedtype Content
    init(content: () -> Content)
}

extension ContainerView {
    init(@ViewBuilder _ content: () -> Content) {
        self.init(content: content)
    }
}
