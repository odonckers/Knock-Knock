//
//  CollectionItem.swift
//  Knock Knock
//
//  Created by Owen Donckers on 6/26/21.
//

import CoreData
import UIKit

struct CollectionSection: Hashable, Identifiable {
    let id: String
    let title: String
}

struct CollectionItem: Hashable, Identifiable {
    let id: String
    private(set) var object: NSManagedObject?
    private(set) var type: ItemType
    private(set) var systemImage: String? = nil
    private(set) var title: String? = nil
    private(set) var subtitle: String? = nil
    private(set) var foregroundColor: UIColor? = nil
    private(set) var hasChild: Bool = false

    static func header(
        systemImage: String? = nil,
        title: String,
        foregroundColor: UIColor = .label,
        id: String = UUID().uuidString
    ) -> Self {
        CollectionItem(
            id: id,
            type: .header,
            systemImage: systemImage,
            title: title,
            foregroundColor: foregroundColor
        )
    }

    static func row(
        systemImage: String? = nil,
        title: String,
        subtitle: String? = nil,
        foregroundColor: UIColor? = nil,
        hasChild: Bool = false,
        id: String = UUID().uuidString,
        object: NSManagedObject? = nil
    ) -> Self {
        CollectionItem(
            id: id,
            object: object,
            type: .row,
            systemImage: systemImage,
            title: title,
            subtitle: subtitle,
            foregroundColor: foregroundColor,
            hasChild: hasChild
        )
    }

    enum ItemType: Int {
        case header, row
    }
}
