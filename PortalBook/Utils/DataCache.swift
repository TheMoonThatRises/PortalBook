//
//  DataCache.swift
//  PortalBook
//
//  Created by Peter Duanmu on 8/19/24.
//

import Foundation
import StudentVue

@MainActor
class DataCache: ObservableObject {

    private enum CacheItem {
        case studentInfo,
             studentCalendar,
             courseHistory,
             attendance,
             gradeBook,
             classSchedule,
             studentHealthInfo,
             schoolInfo

        static let allValues = [studentInfo,
                                studentCalendar,
                                courseHistory,
                                attendance,
                                gradeBook,
                                classSchedule,
                                studentHealthInfo,
                                schoolInfo]
    }

    private static let cacheDuration: Double = 8 * 60 * 60

    private var accountHash: String

    private var cacheItemInfo: [CacheItem: (Double, Task<Void, Error>?)]

    @Published public private(set) var studentInfo: StudentVueApi.StudentInfo? {
        didSet {
            studentInfoLoaded = studentInfo != nil
        }
    }
    @Published public private(set) var studentCalendar: StudentVueApi.StudentCalendar? {
        didSet {
            studentCalendarLoaded = studentCalendar != nil
        }
    }
    @Published public private(set) var courseHistory: StudentVueScraper.CourseHistory? {
        didSet {
            courseHistoryLoaded = courseHistory != nil
        }
    }
    @Published public private(set) var attendance: StudentVueApi.Attendance? {
        didSet {
            attendanceLoaded = attendance != nil
        }
    }
    @Published public private(set) var gradeBook: StudentVueApi.GradeBook? {
        didSet {
            gradeBookLoaded = gradeBook != nil
        }
    }
    @Published public private(set) var classSchedule: StudentVueApi.ClassSchedule? {
        didSet {
            classScheduleLoaded = classSchedule != nil
        }
    }
    @Published public private(set) var studentHealthInfo: StudentVueApi.StudentHealthInfo? {
        didSet {
            studentHealthInfoLoaded = studentHealthInfo != nil
        }
    }
    @Published public private(set) var schoolInfo: StudentVueApi.SchoolInfo? {
        didSet {
            schoolInfoLoaded = schoolInfo != nil
        }
    }

    @Published public private(set) var studentInfoLoaded = false
    @Published public private(set) var studentCalendarLoaded = false
    @Published public private(set) var courseHistoryLoaded = false
    @Published public private(set) var attendanceLoaded = false
    @Published public private(set) var gradeBookLoaded = false
    @Published public private(set) var classScheduleLoaded = false
    @Published public private(set) var studentHealthInfoLoaded = false
    @Published public private(set) var schoolInfoLoaded = false

    @Published public private(set) var isCacheLoaded = false

    private var cacheStatus: Bool {
        studentInfoLoaded && studentCalendarLoaded && courseHistoryLoaded && attendanceLoaded && gradeBookLoaded &&
        classScheduleLoaded && studentHealthInfoLoaded && schoolInfoLoaded
    }

    public init() {
        self.cacheItemInfo = [:]

        for item in CacheItem.allValues {
            self.cacheItemInfo[item] = (0.0, nil)
        }

        accountHash = ""
    }

    private func loadCacheItem(item: Any?,
                               type: CacheItem,
                               force: Bool,
                               taskItem: @escaping () async throws -> Void) throws {
        let cacheItem = cacheItemInfo[type]

        if let cacheItem = cacheItem {
            let shouldLoad = item == nil ||
                             force ||
                             Date.now.timeIntervalSince1970 - cacheItem.0 > DataCache.cacheDuration

            if shouldLoad {
                if let task = cacheItem.1, !task.isCancelled {
                    task.cancel()
                }

                cacheItemInfo[type]?.1 = Task { @MainActor in
                    isCacheLoaded = false
                    try await taskItem()
                    cacheItemInfo[type]?.0 = Date.now.timeIntervalSince1970
                    isCacheLoaded = cacheStatus
                }
            }
        } else {
            cacheItemInfo[type] = (0, nil)
            try loadCacheItem(item: item, type: type, force: force, taskItem: taskItem)
        }
    }

    public func reloadCache(client: StudentVue, force: Bool) throws {
        let svHash = client.getAccountHash()

        var forceReload = force

        if accountHash != svHash {
            accountHash = svHash
            forceReload = true
        }

        try reloadStudentInfo(client: client, force: forceReload)
        try reloadStudentCalendar(client: client, force: forceReload)
        try reloadCourseHistory(client: client, force: forceReload)
        try reloadAttendance(client: client, force: forceReload)
        try reloadGradeBook(client: client, force: forceReload)
        try reloadClassSchedule(client: client, force: forceReload)
        try reloadStudentHealthInfo(client: client, force: forceReload)
        try reloadSchoolInfo(client: client, force: forceReload)
    }

    public func reloadStudentInfo(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: studentInfo, type: .studentInfo, force: force) {
            self.studentInfo = nil
            self.studentInfo = try await client.api.getStudentInfo()
        }
    }

    public func reloadStudentCalendar(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: studentCalendar, type: .studentCalendar, force: force) {
            self.studentCalendar = nil
            self.studentCalendar = try await client.api.getCalendar()
        }
    }

    public func reloadCourseHistory(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: courseHistory, type: .courseHistory, force: force) {
            self.courseHistory = nil
            self.courseHistory = try await client.scraper.getCourseHistory()
        }
    }

    public func reloadAttendance(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: attendance, type: .attendance, force: force) {
            self.attendance = nil
            self.attendance = try await client.api.getAttendence()
        }
    }

    public func reloadGradeBook(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: gradeBook, type: .gradeBook, force: force) {
            self.gradeBook = nil
            self.gradeBook = try await client.api.getGradeBook()
        }
    }

    public func reloadClassSchedule(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: classSchedule, type: .classSchedule, force: force) {
            self.classSchedule = nil
            self.classSchedule = try await client.api.getClassSchedule()
        }
    }

    public func reloadStudentHealthInfo(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: studentHealthInfo, type: .studentHealthInfo, force: force) {
            self.studentHealthInfo = nil
            self.studentHealthInfo = try await client.api.getHealthInfo()
        }
    }

    public func reloadSchoolInfo(client: StudentVue, force: Bool) throws {
        try loadCacheItem(item: schoolInfo, type: .schoolInfo, force: force) {
            self.schoolInfo = nil
            self.schoolInfo = try await client.api.getSchoolInfo()
        }
    }

}
