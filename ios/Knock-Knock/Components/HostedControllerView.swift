//
//  HostedControllerView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/26/21.
//

import SwiftUI

protocol HostedControllerView: View {
    var dismiss: (() -> Void)? { get set }
}

class HostingController<V: HostedControllerView>: UIHostingController<V> {
    override init(rootView: V) {
        super.init(rootView: rootView)
        self.rootView.dismiss = dismiss
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
