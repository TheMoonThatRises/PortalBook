//
//  CharacterSet+numbers.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/21/24.
//

import Foundation

extension CharacterSet {
    static let numbers = CharacterSet(charactersIn: "0123456789").inverted
}
