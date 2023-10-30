//
//  PortalKeychain.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/14/23.
//

import Foundation
import KeychainAccess

struct Credentials: Codable {
    var username: String
    var password: String
    var domain: String
}

class PortalKeychain {
    public static let shared = PortalKeychain()

    private let keychain = Keychain(service: tag)

    private static let tag = "com.themoonthatrises.keychain"

    private static func credentialsToData(credentials: Credentials) throws -> Data {
        return try PropertyListEncoder.init().encode(credentials)
    }

    private static func dataToCredentials(data: Data) throws -> Credentials {
        return try PropertyListDecoder.init().decode(Credentials.self, from: data)
    }

    public func save(username: String, password: String, domain: String) async throws {
        let credentials = Credentials(username: username, password: password, domain: domain)

        let data = try PortalKeychain.credentialsToData(credentials: credentials).base64EncodedString()

        Task {
            try keychain
                .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: [.biometryCurrentSet])
                .set(data, key: domain)
        }
    }

    public func getItem(domain: String) async throws -> Credentials {
        let item = try keychain
            .authenticationPrompt("Authenticate to login")
            .get(domain)

        guard let item = item, let data = Data(base64Encoded: item) else {
            throw Errors.noData
        }

        return try PortalKeychain.dataToCredentials(data: data)
    }

    public func updateItem(username: String, password: String, domain: String) async throws {
        let credentials = Credentials(username: username, password: password, domain: domain)

        let data = try PortalKeychain.credentialsToData(credentials: credentials).base64EncodedString()

        Task {
            try keychain
                .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: [.biometryCurrentSet])
                .authenticationPrompt("Authenticate to update your login details")
                .set(data, key: domain)
        }
    }

    public func removeItem(domain: String) async throws {
        try keychain.remove(domain)
    }

}
