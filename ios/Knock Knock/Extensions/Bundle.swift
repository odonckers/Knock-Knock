//
//  Bundle.swift
//  Knock Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import SwiftUI

extension Bundle {
    var icon: Image? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return Image(lastIcon)
        }
        return nil
    }

    static var appName: String {
        guard let name = main.infoDictionary?["CFBundleName"] as? String else { return "" }
        return name
    }

    static var appVersionMarketing: String {
        guard let name = main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return name
    }

    static var appVersionBuild: String {
        let bundleKey = kCFBundleVersionKey as String
        guard let version = main.object(forInfoDictionaryKey: bundleKey) as? String else {
            return "0"
        }
        return version
    }

    static var copyrightHumanReadable: String {
        guard let name = main.infoDictionary?["NSHumanReadableCopyright"] as? String else {
            return ""
        }
        return name
    }
}
