//
//  SplitViewController.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/9/21.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    init() {
        super.init(style: .tripleColumn)
        delegate = self
        preferredDisplayMode = .twoDisplaceSecondary
        showsSecondaryOnlyButton = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var sidebarViewController: SidebarViewController!
    private var recordsViewController: RecordsViewController!
    private var doorsViewController: DoorsViewController!

    private var compactRecordsViewController: RecordsViewController!
    private var compactTerrititoriesViewController: TerritoriesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSidebarViewController()
        setupRecordsViewController()
        setupDoorsViewContorller()
        setupCompactViewController()
    }
}

extension SplitViewController {
    private func setupSidebarViewController() {
        sidebarViewController = SidebarViewController()
        setViewController(sidebarViewController, for: .primary)
    }

    private func setupRecordsViewController() {
        recordsViewController = RecordsViewController()

        let navigationController = UINavigationController(
            rootViewController: recordsViewController
        )
        setViewController(navigationController, for: .supplementary)
    }

    private func setupDoorsViewContorller() {
        doorsViewController = DoorsViewController()

        let navigationController = UINavigationController(
            rootViewController: doorsViewController
        )
        setViewController(navigationController, for: .secondary)
    }
}

extension SplitViewController {
    private func setupCompactViewController() {
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [
                compactRecordsNavigationController(),
                compactTerritoriesNavigationController(),
            ],
            animated: false
        )
        setViewController(tabBarController, for: .compact)
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
