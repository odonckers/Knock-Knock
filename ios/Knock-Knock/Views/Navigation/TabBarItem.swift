//
//  TabBarItem.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/23/21.
//

import UIKit

enum TabBarItem: Int, CaseIterable {
    case records, territories

    var title: String {
        switch self {
        case .records: return "Records"
        case .territories: return "Territories"
        }
    }

    var image: UIImage? {
        switch self {
        case .records: return UIImage(systemName: "note.text")
        case .territories: return UIImage(systemName: "rectangle.stack.fill")
        }
    }
}
