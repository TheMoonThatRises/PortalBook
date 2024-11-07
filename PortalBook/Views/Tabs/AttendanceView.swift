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
    var period: String
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

    @State var foregroundStyleColors: [String: Color] = [:]

    var body: some View {
        let item: KeyValuePairs<String, Color> = [:]

        NavigationStack {
            if !attendanceData.isEmpty {
                Chart {
                    ForEach(attendanceData) { data in
                        if data.count > 0 {
                            BarMark(
                                x: .value("Period", data.period),
                                y: .value("Count", data.count)
                            )
                            .foregroundStyle(data.color)
                            .annotation(position: .overlay, alignment: .center) {
                                Text("\(data.count)")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .chartForegroundStyleScale(item)
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .refreshable {
                    refresh.toggle()
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

    // swiftlint:disable:next cyclomatic_complexity
    private func populateAttendance() {
        if let attendance = dataCache.attendance {
            attendanceData.removeAll()

            for excused in attendance.totalExcused {
                attendanceData.append(.init(color: .excused,
                                            period: String(excused.period),
                                            count: excused.total))

                if excused.total > 0 {
                    foregroundStyleColors["Excused"] = Color.excused
                }
            }

            for tardy in attendance.totalTardies {
                attendanceData.append(.init(color: .tardies,
                                            period: String(tardy.period),
                                            count: tardy.total))

                if tardy.total > 0 {
                    foregroundStyleColors["Tardy"] = Color.tardies
                }
            }

            for unexcused in attendance.totalUnexcused {
                attendanceData.append(.init(color: .unexcused,
                                            period: String(unexcused.period),
                                            count: unexcused.total))

                if unexcused.total > 0 {
                    foregroundStyleColors["Unexcused"] = Color.unexcused
                }
            }

            for activity in attendance.totalActivities {
                attendanceData.append(.init(color: .activities,
                                            period: String(activity.period),
                                            count: activity.total))

                if activity.total > 0 {
                    foregroundStyleColors["Activity"] = Color.activities
                }
            }

            for unexcusedTardy in attendance.totalUnexcusedTardies {
                attendanceData.append(.init(color: .unexcusedTardies,
                                            period: String(unexcusedTardy.period),
                                            count: unexcusedTardy.total))

                if unexcusedTardy.total > 0 {
                    foregroundStyleColors["Unexcused Tardy"] = Color.unexcusedTardies
                }
            }

            attendanceData.sort(by: { $0.period < $1.period })
        }
    }
}
