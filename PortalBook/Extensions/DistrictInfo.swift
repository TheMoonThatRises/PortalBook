//
//  DistrictInfo.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/25/23.
//

import Foundation
import StudentVue

extension StudentVueApi.DistrictInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(districtID)
    }

    public static func == (lhs: StudentVueApi.DistrictInfo, rhs: StudentVueApi.DistrictInfo) -> Bool {
        lhs.districtID == rhs.districtID
    }
}
