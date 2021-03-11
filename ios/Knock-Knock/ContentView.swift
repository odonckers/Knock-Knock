//
//  ContentView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    private var isCompact: Bool {
        horizontalSizeClass == .compact ||
            UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some View {
        if isCompact {
            TabNavigationView()
        } else {
            SidebarNavigationView()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
    }
}
#endif
