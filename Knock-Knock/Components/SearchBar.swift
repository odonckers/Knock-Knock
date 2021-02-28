//
//  SearchBar.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

class SearchBar: NSObject, ObservableObject {
    @Published var text = ""

    let searchController = UISearchController(searchResultsController: nil)

    override init() {
        super.init()

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchBarText = searchController.searchBar.text {
            self.text = searchBarText
        }
    }
}

struct SearchBarModifier: ViewModifier {
    let searchBar: SearchBar

    func body(content: Content) -> some View {
        content.overlay(
            ViewControllerResolver { viewController in
                viewController.navigationItem.searchController = searchBar.searchController
            }
            .frame(width: 0, height: 0)
        )
    }
}

extension View {
    func add(searchBar: SearchBar) -> some View {
        self.modifier(SearchBarModifier(searchBar: searchBar))
    }
}

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Text("Hello, World!")
                Text("Hello, World!")
                Text("Hello, World!")
            }
            .navigationTitle("Hello, World!")
            .add(searchBar: SearchBar())
        }
    }
}
#endif
