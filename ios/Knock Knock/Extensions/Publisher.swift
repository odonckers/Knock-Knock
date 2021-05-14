//
//  Publisher.swift
//  Knock Knock
//
//  Created by Owen Donckers on 5/12/21.
//

import CoreData
import Combine
import UIKit

extension Publisher {
    public func apply<Section, Item>(
        to dataSource: UITableViewDiffableDataSource<Section, Item>
    ) -> AnyCancellable
    where Output == NSDiffableDataSourceSnapshot<Section, Item>, Failure == Never {
        sink { snapshot in
            dataSource.apply(snapshot)
        }
    }

    public func apply<Section, Item, TranslatedItem>(
        to dataSource: UITableViewDiffableDataSource<Section, TranslatedItem>,
        translate: @escaping (_ item: Item) -> TranslatedItem
    ) -> AnyCancellable
    where Output == NSDiffableDataSourceSnapshot<Section, Item>, Failure == Never {
        sink { snapshot in
            var newSnapshot = NSDiffableDataSourceSnapshot<Section, TranslatedItem>()
            newSnapshot.appendSections(snapshot.sectionIdentifiers)
            snapshot.sectionIdentifiers.forEach { section in
                let items = snapshot.itemIdentifiers(inSection: section)
                let translatedItems = items.map { item in translate(item) }
                newSnapshot.appendItems(translatedItems, toSection: section)
            }

            dataSource.apply(newSnapshot)
        }
    }
}
