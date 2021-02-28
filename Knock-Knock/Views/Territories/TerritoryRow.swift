//
//  TerritoryRow.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

struct TerritoryRow: View {
    @ObservedObject var territory: Territory

    var body: some View {
        HStack {
            Image(systemName: "folder")
                .font(.title2)
                .foregroundColor(.accentColor)
            Spacer().frame(width: 16)
            VStack(alignment: .leading) {
                Text(territory.wrappedName)
                    .font(.headline)
                Text("\(territory.recordCount) records")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryLabelColor"))
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct TerritoryRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let territory = Territory(context: viewContext)
        territory.name = "D2D-50"

        return TerritoryRow(territory: territory)
            .frame(width: 414, alignment: .leading)
            .padding(.horizontal)
            .previewLayout(.sizeThatFits)
    }
}
#endif
