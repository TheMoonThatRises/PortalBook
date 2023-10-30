//
//  StudentVueIdentifiables.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/27/23.
//

import Foundation
import StudentVue

extension StudentVueApi.GradeBookAssignment: Identifiable {
    public var id: String {
        gradeBookID
    }
}

extension StudentVueApi.GradeBookResource: Identifiable {
    public var id: String {
        resourceID
    }
}

extension StudentVueApi.ClassListSchedule: Identifiable {
    public var id: String {
        sectionGU
    }
}

extension StudentVueApi.SchoolScheduleInfo: Identifiable {
    public var id: String {
        schoolName + bellScheduleName
    }
}

extension StudentVueApi.ClassScheduleInfo: Identifiable {
    public var id: String {
        sectionGU
    }
}
