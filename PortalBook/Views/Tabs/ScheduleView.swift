//
//  ScheduleView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 10/28/23.
//

import SwiftUI
import StudentVue
import AlertToast

struct ScheduleView: View {
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var schedule: StudentVueApi.ClassSchedule? {
        didSet {
            if schedule == nil {
                refresh.toggle()
            }
        }
    }
    
    @State var selectedTodayClass: StudentVueApi.ClassScheduleInfo?
    @State var selectedClassList: StudentVueApi.ClassListSchedule?

    var body: some View {
        NavigationStack {
            if let schedule = schedule {
                VStack(alignment: .leading) {
                    Text("Today's Schedule")
                        .bold()
                        .font(.title)
                    if let todayScheduleInfo = schedule.todayScheduleInfo {
                        HStack {
                            Text("Today: ")
                            Text(todayScheduleInfo.date, format: .dateTime)
                        }
                        .font(.title2)
                        ForEach(todayScheduleInfo.schoolInfos) { schoolInfo in
                            HStack {
                                Text("\(schoolInfo.schoolName): \(schoolInfo.bellScheduleName)")
                                List(schoolInfo.classes) { classInfo in
                                    Button {
                                        selectedTodayClass = classInfo
                                    } label: {
                                        HStack {
                                            Text("\(classInfo.period): ")
                                            Text(classInfo.className)
                                            Spacer()
                                            Text(classInfo.startTime, format: .dateTime)
                                            Text("-")
                                            Text(classInfo.endTime, format: .dateTime)
                                            Spacer()
                                            Text(classInfo.roomName)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("No schedule for today")
                    }
                    Divider()
                        .padding()
                    Text("All Classes")
                        .bold()
                        .font(.title)
                    HStack(alignment: .center) {
                        List(schedule.classLists) { scheduleClass in
                            Button {
                                selectedClassList = scheduleClass
                            } label: {
                                HStack {
                                    Text("\(scheduleClass.period): ")
                                    Text(scheduleClass.courseTitle)
                                    Spacer()
                                    Text(scheduleClass.roomName)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Schedule: \(schedule?.termIndexName ?? "Unknown")")
        .toolbar {
            ToolbarItem {
                Button {
                    schedule = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { schedule == nil ? schedule = nil : nil }
        .onChange(of: refresh) {
            Task {
                defer {
                    loadingMessage = .empty
                }

                loadingMessage = .loadingSchedule

                do {
                    schedule = try await client.api.getClassSchedule()
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
        .sheet(item: $selectedTodayClass) { selected in
            DetailedTodayClassScheduleView(todayClass: selected)
        }
        .sheet(item: $selectedClassList) { selected in
            DetailedClassListScheduleView(scheduleClass: selected)
        }
    }
}

struct DetailedTodayClassScheduleView: View {
    @Environment(\.dismiss) var dismiss

    var todayClass: StudentVueApi.ClassScheduleInfo

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Period")
                    Spacer()
                    Text("\(todayClass.period)")
                }
                Divider()
                GridRow {
                    Text("Room")
                    Spacer()
                    Text(todayClass.roomName)
                }
                Divider()
                GridRow {
                    Text("Start Time")
                    Spacer()
                    Text(todayClass.startTime, format: .dateTime)
                }
                Divider()
                GridRow {
                    Text("End Time")
                    Spacer()
                    Text(todayClass.endTime, format: .dateTime)
                }
                Divider()
                GridRow {
                    Text("Teacher")
                    Spacer()
                    Text(todayClass.teacherName)
                }
                Divider()
                GridRow {
                    Text("Teacher Email")
                    Spacer()
                    Text(todayClass.teacherEmail)
                }
                Divider()
                GridRow {
                    Text("Class Link")
                    Spacer()
                    Text(.init("[\(todayClass.classURL)](\(todayClass.classURL)"))
                }
            }
            .padding()
            .navigationTitle(todayClass.className)
            .toolbar {
                ToolbarItem {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailedClassListScheduleView: View {
    @Environment(\.dismiss) var dismiss

    var scheduleClass: StudentVueApi.ClassListSchedule

    var body: some View {
        NavigationStack {
            Grid {
                GridRow {
                    Text("Period")
                    Spacer()
                    Text("\(scheduleClass.period)")
                }
                Divider()
                GridRow {
                    Text("Room")
                    Spacer()
                    Text(scheduleClass.roomName)
                }
                Divider()
                GridRow {
                    Text("Teacher")
                    Spacer()
                    Text(scheduleClass.teacher)
                }
                Divider()
                GridRow {
                    Text("Teacher Email")
                    Spacer()
                    Text(scheduleClass.teacherEmail)
                }
            }
            .padding()
            .navigationTitle(scheduleClass.courseTitle)
            .toolbar {
                ToolbarItem {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
