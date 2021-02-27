//
//  Introspect+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/27/21.
//

import Introspect
import SwiftUI

extension View {
    public func introspectSplitViewController(customize: @escaping (UISplitViewController) -> ()) -> some View {
        return inject(UIKitIntrospectionViewController(
            selector: { introspectionViewController in
                // Search in ancestors
                if let splitViewController = introspectionViewController.splitViewController {
                    return splitViewController
                }
                
                // Search in siblings
                return Introspect.previousSibling(containing: UISplitViewController.self, from: introspectionViewController)
            },
            customize: customize
        ))
    }
}
