//
//  TabNavigationView.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct TabNavigationView: View {
    @SceneStorage("tabNavigation.selection")
    private var selection: Int = 0
        
    var body: some View {
        TabView(selection: $selection) {
            NavigationView { RecordsView() }
                .tabItem { RecordsLabel() }
            .tag(NavigationItem.recordList.rawValue)
            
            NavigationView { TerritoriesView() }
                .tabItem {
                    Label(
                        "Territories",
                        systemImage: "rectangle.stack.fill"
                    )
                }
            .tag(NavigationItem.territoryList.rawValue)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension TabNavigationView {
    enum NavigationItem: Int {
        case recordList = 0
        case territoryList = 1
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}
