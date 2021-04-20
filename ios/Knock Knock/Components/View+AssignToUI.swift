//
//  View+AssignToUI.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/10/21.
//

import SwiftUI
import UIKit

extension View {
    @discardableResult public func assignToUI(
        navigationController: UINavigationController
    ) -> some View {
        let viewController = UIHostingController(rootView: self)
        navigationController.setViewControllers([viewController], animated: false)
        return self
    }
}
