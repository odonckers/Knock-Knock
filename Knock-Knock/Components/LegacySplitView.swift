//
//  LegacySplitView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/24/21.
//

import SwiftUI
import UIKit

struct LegacySplitView<Primary: View, Supplementary: View, Secondary: View, Compact: View>: UIViewControllerRepresentable {
    let style: UISplitViewController.Style
        
    @State var displayMode: UISplitViewController.DisplayMode = .automatic
    @State var splitBehavior: UISplitViewController.SplitBehavior = .automatic
    
    @State var primary: () -> Primary
    @State var supplementary: () -> Supplementary? = { nil }
    @State var secondary: () -> Secondary
    @State var compact: () -> Compact? = { nil }
    
    func makeUIViewController(context: Context) -> UISplitViewController {
        let vc = UISplitViewController(style: style)
        return vc
    }

    func updateUIViewController(_ vc: UISplitViewController, context: Context) {
        vc.preferredDisplayMode = displayMode
        vc.preferredSplitBehavior = splitBehavior
        
        vc.setViewController(UIHostingController(rootView: primary()), for: .primary)
        vc.setViewController(UIHostingController(rootView: supplementary()), for: .supplementary)
        vc.setViewController(UIHostingController(rootView: secondary()), for: .secondary)
        
        vc.setViewController(UIHostingController(rootView: compact()), for: .compact)
    }
}

extension LegacySplitView {
    public func displayMode(_ displayMode: UISplitViewController.DisplayMode) -> LegacySplitView {
        self.displayMode = displayMode
        return self
    }
    
    public func splitBehavior(_ splitBehavior: UISplitViewController.SplitBehavior) -> LegacySplitView {
        self.splitBehavior = splitBehavior
        return self
    }
    
    @inlinable public func setPrimary(@ViewBuilder _ v: @escaping () -> Primary) -> LegacySplitView {
        primary = v
        return self
    }
    
    @inlinable public func setSupplementary(@ViewBuilder _ v: @escaping () -> Supplementary) -> LegacySplitView {
        supplementary = v
        return self
    }
    
    @inlinable public func setSecondary(@ViewBuilder _ v: @escaping () -> Secondary) -> LegacySplitView {
        secondary = v
        return self
    }
    
    @inlinable public func setCompact(@ViewBuilder _ v: @escaping () -> Compact) -> LegacySplitView {
        compact = v
        return self
    }
}

struct LegacySplitView_Previews: PreviewProvider {
    static var previews: some View {        
        LegacySplitView(
            style: .doubleColumn,
            primary: {
                EmptyView()
                    .background(Color(.green))
            },
            supplementary: {
                EmptyView()
                    .background(Color(.green))
            },
            secondary: {
                EmptyView()
                    .background(Color(.green))
            },
            compact: {
                EmptyView()
                    .background(Color(.green))
            }
        )
        .displayMode(.twoBesideSecondary)
        .splitBehavior(.tile)
    }
}
