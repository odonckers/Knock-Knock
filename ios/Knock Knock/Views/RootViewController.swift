//
//  RootViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import UIKit

class RootViewController: UIViewController {
    private lazy var primaryViewController = makePrimaryViewController()
    private lazy var sidebarViewController = makeSidebarViewController()
    private lazy var secondaryViewController = makeSecondaryViewController()
    private lazy var compactViewController = makeCompactViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        primaryViewController.setViewController(sidebarViewController, for: .primary)
        primaryViewController.setViewController(secondaryViewController, for: .secondary)
        primaryViewController.setViewController(compactViewController, for: .compact)

        view.addSubview(primaryViewController.view)
        addChild(primaryViewController)
        primaryViewController.didMove(toParent: self)
    }
}

extension RootViewController {
    private func makePrimaryViewController() -> UISplitViewController {
        let primaryViewController = UISplitViewController(style: .doubleColumn)

        primaryViewController.delegate = self
        primaryViewController.preferredDisplayMode = .oneBesideSecondary
        primaryViewController.preferredSplitBehavior = .tile

        primaryViewController.view.frame = view.bounds
        primaryViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return primaryViewController
    }

    private func makeSidebarViewController() -> UIViewController {
        let sidebarViewController = RecordsViewController(isCompact: false)
        return sidebarViewController
    }

    private func makeSecondaryViewController() -> UINavigationController {
        let moc = PersistenceController.shared.container.viewContext
        let navigationController = UINavigationController()

        DoorsView.emptyBody
            .environment(\.managedObjectContext, moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        return navigationController
    }

    private func makeCompactViewController() -> UINavigationController {
        let recordsViewController = RecordsViewController(isCompact: true)
        let navigationController = UINavigationController(rootViewController: recordsViewController)
        return navigationController
    }
}

extension RootViewController: UISplitViewControllerDelegate { }
