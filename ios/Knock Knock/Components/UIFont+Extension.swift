//
//  UIFont+Extension.swift
//  Knock Knock
//
//  Created by Owen Donckers on 3/27/21.
//

import UIKit

extension UIFont {
    public func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
