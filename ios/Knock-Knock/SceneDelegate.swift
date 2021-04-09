//
//  SceneDelegate.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 3/3/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        let splitViewController = UISplitViewController(style: .tripleColumn)
        splitViewController.preferredDisplayMode = .twoDisplaceSecondary
        splitViewController.showsSecondaryOnlyButton = true

        let sidebarViewController = SidebarViewController()
        splitViewController
            .setViewController(sidebarViewController, for: .primary)

        let recordsViewController = RecordsViewController()
        let recordsNavigationController = UINavigationController(
            rootViewController: recordsViewController
        )
        splitViewController
            .setViewController(recordsNavigationController, for: .supplementary)

        let doorsViewController = DoorsViewController()
        let doorsNavigationController = UINavigationController(
            rootViewController: doorsViewController
        )
        splitViewController
            .setViewController(doorsNavigationController, for: .secondary)

        let compactRecordsViewController = RecordsViewController(
            isCompact: true
        )
        let compactRecordsNavigationController = UINavigationController(
            rootViewController: compactRecordsViewController
        )

        let compactTerritoriesViewController = TerritoriesViewController()
        let compactTerritoriesNavigationContorller = UINavigationController(
            rootViewController: compactTerritoriesViewController
        )

        let tabBarController = UITabBarController()
        tabBarController.setViewControllers(
            [
                compactRecordsNavigationController,
                compactTerritoriesNavigationContorller
            ],
            animated: false
        )
        splitViewController.setViewController(tabBarController, for: .compact)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = splitViewController
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistenceController.container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
