//
//  KnockKnockApp.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

@main
struct KnockKnockApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView().environment(
                \.managedObjectContext,
                persistenceController.container.viewContext
            )
        }
        .commands {
            SidebarCommands()
        }
    }
}
