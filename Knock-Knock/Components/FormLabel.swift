//
//  FormLabel.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct FormLabel<Source: View>: View {
    let source: Source
    let label: String
    let position: Alignment

    var body: some View {
        HStack {
            if position == .leading {
                formLabel
                Spacer()
            }
            source
            if position == .trailing {
                Spacer()
                formLabel
            }
        }
        .font(.body)
    }

    @ViewBuilder private var formLabel: some View {
        Text(label)
            .foregroundColor(.placeholderText)
            .frame(minWidth: 100, alignment: position)
    }
}

extension View {
    @ViewBuilder public func formLabel(
        _ label: String,
        position: Alignment = .leading
    ) -> some View {
        FormLabel(source: self, label: label, position: position)
    }
}

#if DEBUG
struct FormLabel_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            StatefulPreviewWrapper("Inputted Text") {
                TextField("Type here", text: $0)
                    .formLabel("Label")
            }
        }
    }
}
#endif
