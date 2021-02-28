//
//  DeleteConfirmation.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct DeleteConfirmation<Source: DynamicViewContent>: View {
    let source: Source
    let title: (IndexSet) -> String
    let message: String?
    let perform: (IndexSet) -> Void

    @State var indexSet = IndexSet()
    @State var isPresented = false

    var body: some View {
        source
            .onDelete { indexSet in
                self.indexSet = indexSet
                isPresented = true
            }
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text(title(indexSet)),
                    message: message == nil ? nil : Text(message!),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(
                        Text("Delete"),
                        action: {
                            withAnimation { perform(indexSet) }
                        }
                    )
                )
            }
    }
}

extension DynamicViewContent {
    @ViewBuilder public func onConfirmedDelete(
        title: @escaping (IndexSet) -> String,
        message: String? = nil,
        perform: @escaping (IndexSet) -> Void
    ) -> some View {
        DeleteConfirmation(
            source: self,
            title: title,
            message: message,
            perform: perform
        )
    }
}

#if DEBUG
struct DeleteConfirmation_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(0..<10) { i in
                Text("Index \(i)")
            }
            .onConfirmedDelete(
                title: { _ in
                    "Are you sure?"
                },
                message: "This is serious..."
            ) { index in
                print(index)
            }
        }
    }
}
#endif
