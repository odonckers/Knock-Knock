//
//  RecordsLabel.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct RecordsLabel: View {
    var body: some View {
        Label("Records", systemImage: "note.text")
    }
}

struct RecordsLabel_Previews: PreviewProvider {
    static var previews: some View {
        RecordsLabel()
            .frame(width: 240, alignment: .leading)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
