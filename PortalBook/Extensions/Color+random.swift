//
//  UIColor+random.swift
//  PortalBook
//
//  Created by Peter Duanmu on 8/19/24.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
