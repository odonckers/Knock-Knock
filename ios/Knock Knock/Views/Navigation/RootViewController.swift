//
//  RootViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import UIKit

class RootViewController: UIViewController {
    private var primaryViewController: UIViewController!

    private var sidebarViewController: SidebarViewController!
    private var recordsViewController: RecordsViewController!

    private var compactRecordsViewController: RecordsViewController!
    private var compactTerrititoriesViewController: TerritoriesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        switch UIDevice.current.userInterfaceIdiom {
        case .pad: configureSplitViewController()
        default: configureTabViewController()
        }

        view.addSubview(primaryViewController.view)
        addChild(primaryViewController)

        primaryViewController.view.frame = view.bounds
        primaryViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

extension RootViewController {
    private func configureSplitViewController() {
        primaryViewController = UISplitViewController(style: .doubleColumn)

        guard let primaryViewController = primaryViewController as? UISplitViewController
        else { return }
        
        primaryViewController.delegate = self
        primaryViewController.preferredDisplayMode = .oneBesideSecondary
        primaryViewController.showsSecondaryOnlyButton = true

        setupSidebarViewController(in: primaryViewController)
        setupDoorsViewContorller(in: primaryViewController)
        setupCompactViewController(in: primaryViewController)
    }

    private func configureTabViewController() {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [
                compactRecordsNavigationController(),
                compactTerritoriesNavigationController(),
            ],
            animated: false
        )
        primaryViewController = tabBarController
    }
}

extension RootViewController {
    private func setupSidebarViewController(in splitViewController: UISplitViewController) {
        sidebarViewController = SidebarViewController()
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
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [
                compactRecordsNavigationController(),
                compactTerritoriesNavigationController(),
            ],
            animated: false
        )
        splitViewController.setViewController(tabBarController, for: .compact)
    }

    private func compactRecordsNavigationController() -> UINavigationController {
        compactRecordsViewController = RecordsViewController(isCompact: true)

        let navigationController = UINavigationController(
            rootViewController: compactRecordsViewController
        )
        navigationController.tabBarItem.image = TabBarItem.records.image
        navigationController.tabBarItem.title = TabBarItem.records.title
        return navigationController
    }

    private func compactTerritoriesNavigationController() -> UINavigationController {
        compactTerrititoriesViewController = TerritoriesViewController()

        let navigationController = UINavigationController(
            rootViewController: compactTerrititoriesViewController
        )
        navigationController.tabBarItem.image = TabBarItem.territories.image
        navigationController.tabBarItem.title = TabBarItem.territories.title
        return navigationController
    }
}

extension RootViewController: UISplitViewControllerDelegate { }
