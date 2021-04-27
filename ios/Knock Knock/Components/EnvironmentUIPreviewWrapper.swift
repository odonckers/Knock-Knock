//
//  EnvironmentUIPreviewWrapper.swift
//  Knock Knock
//
//  Created by Owen Donckers on 4/23/21.
//

#if DEBUG
import SwiftUI

struct EnvironmentUIPreviewWrapper<V: View>: UIViewControllerRepresentable {
    let child: () -> V

    init(@ViewBuilder child: @escaping () -> V) {
        self.child = child
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let moc = PersistenceController.preview.container.viewContext
        let navigationController = UINavigationController()

        child()
            .environment(\.managedObjectContext, moc)
            .environment(\.uiNavigationController, navigationController)
            .assignToUI(navigationController: navigationController)

        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) { }
}
#endif
