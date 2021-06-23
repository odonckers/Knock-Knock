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
    public func applyingChanges<Changes, ChangeItem>(
        _ changes: Changes,
        _ transform: @escaping (ChangeItem) -> Output.Element
    ) -> AnyPublisher<Output, Failure>
    where Changes: Publisher,
          Output: RangeReplaceableCollection,
          Output.Index == Int,
          Changes.Output == CollectionDifference<ChangeItem>,
          Changes.Failure == Failure
    {
        zip(changes) { existing, changes -> Output in
            var objects = existing
            for change in changes {
                switch change {
                case .remove(let offset, _, _):
                    objects.remove(at: offset)
                case .insert(let offset, let obj, _):
                    let transformed = transform(obj)
                    objects.insert(transformed, at: offset)
                }
            }
            return objects
        }
        .eraseToAnyPublisher()
    }

    public func applyingChanges<Changes, ChangeItem, TransformItem>(
        to parentItem: TransformItem? = nil,
        _ changes: Changes,
        _ transform: @escaping (ChangeItem) -> TransformItem
    ) -> AnyPublisher<Output, Failure>
    where Changes: Publisher,
          Output == NSDiffableDataSourceSectionSnapshot<TransformItem>,
          Changes.Output == CollectionDifference<ChangeItem>,
          Changes.Failure == Failure
    {
        zip(changes) { existing, changes -> Output in
            var snapshot = existing
            var toDelete = [TransformItem]()
            var toAppend = [TransformItem]()
            for change in changes {
                switch change {
                case .remove(_, let item, _):
                    let transformed = transform(item)
                    toDelete.append(transformed)
                case .insert(_, let item, _):
                    let transformed = transform(item)
                    toAppend.append(transformed)
                }
            }
            if toDelete.count > 0 { snapshot.delete(toDelete) }
            if toAppend.count > 0 { snapshot.append(toAppend, to: parentItem) }
            return snapshot
        }
        .eraseToAnyPublisher()
    }

    public func applyingChanges<Changes, ChangeItem, TransformItem>(
        _ changes: Changes,
        _ transform: @escaping (ChangeItem) -> TransformItem,
        onInsert insert: @escaping (
            ChangeItem,
            TransformItem,
            inout NSDiffableDataSourceSectionSnapshot<TransformItem>
        ) -> Void
    ) -> AnyPublisher<Output, Failure>
    where Changes: Publisher,
          Output == NSDiffableDataSourceSectionSnapshot<TransformItem>,
          Changes.Output == CollectionDifference<ChangeItem>,
          Changes.Failure == Failure {
        zip(changes) { existing, changes -> Output in
            var snapshot = existing
            var toDelete = [TransformItem]()
            for change in changes {
                switch change {
                case .remove(_, let item, _):
                    let transformed = transform(item)
                    toDelete.append(transformed)
                case .insert(_, let item, _):
                    let transformed = transform(item)
                    insert(item, transformed, &snapshot)
                }
            }
            if toDelete.count > 0 { snapshot.delete(toDelete) }
            return snapshot
        }
        .eraseToAnyPublisher()
    }

    public func apply<Section, Item>(
        to section: Section,
        in dataSource: UICollectionViewDiffableDataSource<Section, Item>
    ) -> AnyCancellable
    where
        Output == NSDiffableDataSourceSectionSnapshot<Item>,
        Failure == Never
    {
        sink { snapshot in
            dataSource.apply(snapshot, to: section)
        }
    }

    public func apply<Section, Item, Animate>(
        to section: Section,
        in dataSource: UICollectionViewDiffableDataSource<Section, Item>,
        animate: Animate? = nil
    ) -> AnyCancellable
    where
        Animate: Publisher,
        Output == NSDiffableDataSourceSectionSnapshot<Item>,
        Animate.Output == Bool,
        Failure == Never,
        Animate.Failure == Never
    {
        // Animate and Just are different types, so we have to type-erase to be able to use
        // either one for the same parameter.
        let animate = animate?.eraseToAnyPublisher() ?? Just(true).eraseToAnyPublisher()
        return combineLatest(animate).sink { snapshot, animate in
            dataSource.apply(snapshot, to: section, animatingDifferences: animate)
        }
    }
}
