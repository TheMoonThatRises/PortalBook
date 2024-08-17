//
//  URLCache.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 3/15/23.
//

import Foundation

extension URLCache {
    static let iconCache = URLCache(memoryCapacity: 4*1024*1024, diskCapacity: 20*1024*1024) // 4MB and 20MB
}
