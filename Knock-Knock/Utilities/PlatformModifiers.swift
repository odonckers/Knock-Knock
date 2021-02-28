//
//  PlatformModifiers.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension View {
    /// Modify the view in a closure. This can be useful when you need to conditionally apply a modifier that
    /// is unavailable on certain platforms.
    ///
    /// For example, imagine this code needing to run on macOS too where `View#actionSheet()` is
    /// not available:
    /// ```
    /// struct ContentView: View {
    ///     var body: some View {
    ///         Text("Unicorn")
    ///             .modify {
    ///                 #if os(iOS)
    ///                 return $0.actionSheet(…).eraseType()
    ///                 #else
    ///                 return nil
    ///                 #endif
    ///             }
    ///     }
    /// }
    /// ```
    @ViewBuilder func modify(
        @ViewBuilder _ handler: (_: Self) -> AnyView?
    ) -> some View {
        if let content = handler(self) {
            content
        } else {
            self
        }
    }
    
    /// Conditionally apply modifiers depending on the target operating system.
    ///
    /// ```
    /// struct ContentView: View {
    ///    var body: some View {
    ///        Text("Unicorn")
    ///            .font(.system(size: 10))
    ///            .ifOS(.macOS, .tvOS) {
    ///                $0.font(.system(size: 20))
    ///            }
    ///    }
    /// }
    /// ```
    @ViewBuilder func ifOS<Content>(
        _ operatingSystems: OperatingSystem...,
        handler: @escaping (_: Self) -> Content
    ) -> some View where Content: View {
        if operatingSystems.contains(OperatingSystem.current) {
            handler(self)
        } else {
            self
        }
    }
    
    /// Returns a type-erased version of `self`.
    @ViewBuilder func eraseType() -> AnyView {
        AnyView(self)
    }
}

enum OperatingSystem {
    case macOS
    case iOS
    case tvOS
    case watchOS

    #if os(macOS)
    static let current = macOS
    #elseif os(iOS)
    static let current = iOS
    #elseif os(tvOS)
    static let current = tvOS
    #elseif os(watchOS)
    static let current = watchOS
    #else
    #error("Unsupported platform")
    #endif
}
