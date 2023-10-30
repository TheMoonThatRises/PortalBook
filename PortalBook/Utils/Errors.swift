//
//  Errors.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/14/23.
//

import Foundation

enum Errors: LocalizedError {
    case noAuth
    case unexpectedData
    case noData
    case unauthorizedLocation
    case unknown(String?)
}

extension Errors {
    public var errorDescription: String? {
        switch self {
        case .noAuth:
            return "Not authorized"
        case .unexpectedData:
            return "Recieved unexpected data from keychain"
        case .noData:
            return "Keychain no data recieved"
        case .unauthorizedLocation:
            return "No location data authorization"
        case .unknown(let message):
            return message ?? "An unknown error has occured"
        }
    }
}
