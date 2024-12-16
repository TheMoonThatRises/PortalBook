//
//  StudentVueApi+Missing.swift
//  PortalBook
//
//  Created by Peter Duanmu on 8/16/24.
//

import StudentVue

extension StudentVueApi.GradeBookAssignment {
    public var isMissing: Bool {
        notes.lowercased().contains("missing")
    }
}
