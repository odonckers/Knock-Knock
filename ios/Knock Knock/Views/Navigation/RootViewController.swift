//
//  RootViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import UIKit

class RootViewController: UIViewController {
    private var primaryViewController: UISplitViewController!
    private var sidebarViewController: RecordsViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSplitViewController()

        view.addSubview(primaryViewController.view)
        addChild(primaryViewController)
        primaryViewController.didMove(toParent: self)

        primaryViewController.view.frame = view.bounds
        primaryViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

extension RootViewController {
    private func configureSplitViewController() {
        primaryViewController = UISplitViewController(style: .doubleColumn)

        primaryViewController.delegate = self
        primaryViewController.preferredDisplayMode = .oneBesideSecondary
        primaryViewController.showsSecondaryOnlyButton = true

        setupSidebarViewController(in: primaryViewController)
        setupDoorsViewContorller(in: primaryViewController)
        setupCompactViewController(in: primaryViewController)
    }
}

extension RootViewController {
    private func setupSidebarViewController(in splitViewController: UISplitViewController) {
        sidebarViewController = RecordsViewController(isCompact: false)
        splitViewController.setViewController(sidebarViewController, for: .primary)
    }

    private func setupDoorsViewContorller(in splitViewController: UISplitViewController) {
        let moc = PersistenceController.shared.container.viewContext
        let navigationController = UINavigationController()

        DoorsView.emptyBody
            .environment(\.managedObjectContext, moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        splitViewController.setViewController(navigationController, for: .secondary)
    }
}

extension RootViewController {
    private func setupCompactViewController(in splitViewController: UISplitViewController) {
        let recordsViewController = RecordsViewController(isCompact: true)
        let navigationController = UINavigationController(rootViewController: recordsViewController)
        splitViewController.setViewController(navigationController, for: .compact)
    }
}

extension RootViewController: UISplitViewControllerDelegate { }
