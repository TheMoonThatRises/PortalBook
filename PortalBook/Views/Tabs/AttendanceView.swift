//
//  AttendanceView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/16/24.
//

import SwiftUI
import StudentVue
import Charts

enum AttendanceType: String {
    case present = "Present"
    case excused = "Excused"
    case unexcused = "Unexcused"
    case tardies = "Tardies"
    case unexcusedTardies = "Unexcused Tardies"
    case activities = "Activities"
}

struct AttendanceBar: Identifiable {
    var color: Color
//    var type: AttendanceType
    var period: Int
    var count: Int
    var id = UUID()
}

struct AttendanceView: View {
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var attendanceData: [AttendanceBar] = []

    var body: some View {
        NavigationStack {
            if !attendanceData.isEmpty {
                Chart {
                    ForEach(attendanceData) { data in
                        BarMark(
                            x: .value("Period", data.period),
                            y: .value("Count", data.count)
                        )
                        .foregroundStyle(by: .value("Color", data.color.description))
                    }
                }
            } else if loadingMessage == .empty {
                Text("Unable to load attendance")
            }
        }
        .navigationTitle("Attendance")
        .toolbar {
            ToolbarItem {
                Button {
                    refresh.toggle()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            if !dataCache.attendanceLoaded {
                loadingMessage = .loadingAttendance
            } else {
                populateAttendance()
            }
        }
        .onChange(of: dataCache.attendanceLoaded) {
            loadingMessage = dataCache.attendanceLoaded ? .empty : .loadingAttendance

            if dataCache.attendanceLoaded {
                populateAttendance()
            }
        }
        .onChange(of: refresh) {
            do {
                try dataCache.reloadAttendance(client: client, force: true)
            } catch {
                print("error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }

    private func populateAttendance() {
        if let attendance = dataCache.attendance {
            for excused in attendance.totalExcused {
                attendanceData.append(.init(color: .excused,
                                            period: excused.period,
                                            count: excused.total))
            }

            for tardy in attendance.totalTardies {
                attendanceData.append(.init(color: .tardies,
                                            period: tardy.period,
                                            count: tardy.total))
            }

            for unexcused in attendance.totalUnexcused {
                attendanceData.append(.init(color: .unexcused,
                                            period: unexcused.period,
                                            count: unexcused.total))
            }

            for activity in attendance.totalActivities {
                attendanceData.append(.init(color: .activities,
                                            period: activity.period,
                                            count: activity.total))
            }

            for unexcusedTardy in attendance.totalUnexcusedTardies {
                attendanceData.append(.init(color: .unexcusedTardies,
                                            period: unexcusedTardy.period,
                                            count: unexcusedTardy.total))
            }
        }
    }
}
