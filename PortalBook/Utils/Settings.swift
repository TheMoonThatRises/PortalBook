//
//  Settings.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/18/23.
//

import SwiftUI

class Settings {
    public static let shared = Settings()

    @AppStorage("domain") public var domain = ""
    @AppStorage("rememberLogin") public var rememberLogin = false
    @AppStorage("didManuallyLogout") public var didManuallyLogout = false
}
