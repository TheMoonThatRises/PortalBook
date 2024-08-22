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
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false

    @State var selectedTodayClass: StudentVueApi.ClassScheduleInfo?
    @State var selectedClassList: StudentVueApi.ClassListSchedule?

    var body: some View {
        NavigationStack {
            if let schedule = dataCache.classSchedule {
                ScrollView {
                    Text("Today's Schedule")
                        .bold()
                        .font(.title)
                    if let todayScheduleInfo = schedule.todayScheduleInfo {
                        HStack {
                            Text("Today: ")
                            Text(todayScheduleInfo.date.formatted(date: .numeric, time: .omitted))
                        }
                        .padding()
                        .font(.title2)

                        ForEach(todayScheduleInfo.schoolInfos) { schoolInfo in
                            VStack {
                                Text("\(schoolInfo.schoolName): \(schoolInfo.bellScheduleName)")
                                Spacer()
                                Grid {
                                    ForEach(schoolInfo.classes) { classInfo in
                                        Divider()
                                        GridRow {
                                            Button {
                                                selectedTodayClass = classInfo
                                            } label: {
                                                HStack {
                                                    Text("\(classInfo.period): ")
                                                    Text(classInfo.className)
                                                    Spacer()
                                                    Text(classInfo.roomName)
                                                }
                                                .padding()
                                            }
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
                        Grid {
                            ForEach(schedule.classLists) { scheduleClass in
                                Divider()
                                GridRow {
                                    Button {
                                        selectedClassList = scheduleClass
                                    } label: {
                                        HStack {
                                            Text("\(scheduleClass.period): ")
                                            Text(scheduleClass.courseTitle)
                                            Spacer()
                                            Text(scheduleClass.roomName)
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .refreshable {
                    refresh.toggle()
                }
            } else if loadingMessage == .empty {
                Text("Unable to load schedule")
            }
        }
        .navigationTitle("Schedule: \(dataCache.classSchedule?.termIndexName ?? "Unknown")")
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
            if !dataCache.classScheduleLoaded {
                loadingMessage = .loadingSchedule
            }
        }
        .onChange(of: dataCache.classScheduleLoaded) {
            loadingMessage = dataCache.classScheduleLoaded ? .empty : .loadingSchedule
        }
        .onChange(of: refresh) {
            do {
                try dataCache.reloadClassSchedule(client: client, force: true)
            } catch {
                print("error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
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
                    Text(todayClass.startTime.formatted(date: .omitted, time: .shortened))
                }
                Divider()
                GridRow {
                    Text("End Time")
                    Spacer()
                    Text(todayClass.endTime.formatted(date: .omitted, time: .shortened))
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
                    if let email = URL(string: "mailto:\(todayClass.teacherEmail)") {
                        Button {
                            UIApplication.shared.open(email)
                        } label: {
                            Text(todayClass.teacherEmail)
                        }
                    } else {
                        Text(todayClass.teacherEmail)
                    }
                }
                Divider()
                GridRow {
                    Text("Class Link")
                    Spacer()
                    Text(.init("[\(todayClass.classURL)](\(todayClass.classURL))"))
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
                    if let email = URL(string: "mailto:\(scheduleClass.teacherEmail)") {
                        Button {
                            UIApplication.shared.open(email)
                        } label: {
                            Text(scheduleClass.teacherEmail)
                        }
                    } else {
                        Text(scheduleClass.teacherEmail)
                    }
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
