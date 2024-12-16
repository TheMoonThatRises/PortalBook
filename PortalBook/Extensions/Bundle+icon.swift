//
//  Bundle+icon.swift
//  PortalBook
//
//  Created by Peter Duanmu on 12/16/24.
//

import SwiftUI

// https://stackoverflow.com/a/51241158
extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }

        return nil
    }
}
