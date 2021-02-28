//
//  TerritoriesListRow.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension TerritoriesView.SubList {
    struct LclRow: View {
        @ObservedObject var territory: Territory

        var body: some View {
            HStack {
                Image(systemName: "folder")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                FramedSpacer(spacing: .medium, direction: .horizontal)
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
}

#if DEBUG
struct TerritoriesListRow_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.preview.container.viewContext

        let territory = Territory(context: viewContext)
        territory.name = "D2D-50"

        return TerritoriesView.SubList.SubRow(territory: territory)
            .frame(width: 414, alignment: .leading)
            .padding(.horizontal)
            .previewLayout(.sizeThatFits)
    }
}
#endif
