//
//  FramedSpacer.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/28/21.
//

import SwiftUI

struct FramedSpacer: View {
    let spacing: Spacing
    let direction: Direction

    var body: some View {
        switch direction {
        case .horizontal:
            return Spacer()
                .frame(width: spacing.rawValue)
        case .vertical:
            return Spacer()
                .frame(height: spacing.rawValue)
        }
    }
}

extension FramedSpacer {
    enum Direction {
        case horizontal, vertical
    }
}

#if DEBUG
struct FramedSpacer_Previews: PreviewProvider {
    static var previews: some View {
        FramedSpacer(spacing: .small, direction: .horizontal)
    }
}
#endif
