//
//  TabNavigationView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct TabNavigationView: View {
    @SceneStorage("tabNavigation.selection")
    private var selection: NavigationItem = .recordList

    var body: some View {
        TabView(selection: $selection) {
            NavigationView { RecordsView() }
                .tabItem { RecordsLabel() }
                .tag(NavigationItem.recordList)

            NavigationView { TerritoriesView() }
                .tabItem {
                    Label("Territories", systemImage: "rectangle.stack.fill")
                }
                .tag(NavigationItem.territoryList)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension TabNavigationView {
    enum NavigationItem: String {
        case recordList
        case territoryList
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}
