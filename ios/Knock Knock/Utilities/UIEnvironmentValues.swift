//
//  UIEnvironmentValues.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/10/21.
//

import CoreData
import SwiftUI

struct UIParentControllerKey: EnvironmentKey {
    static let defaultValue: UIViewController? = nil
}

struct UINavigationControllerKey: EnvironmentKey {
    static let defaultValue: UINavigationController? = nil
}

extension EnvironmentValues {
    var uiParentController: UIViewController? {
        get { return self[UIParentControllerKey.self] }
        set { self[UIParentControllerKey.self] = newValue }
    }

    var uiNavigationController: UINavigationController? {
        get { return self[UINavigationControllerKey.self] }
        set { self[UINavigationControllerKey.self] = newValue }
    }
}
