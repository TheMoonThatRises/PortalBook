//
//  CalendarView.swift
//  PortalBook
//
//  Created by TheMoonThatRises on 8/19/24.
//

import SwiftUI
import StudentVue
import MijickCalendarView

struct CalendarView: View {
    @Binding var client: StudentVue
    @EnvironmentObject var dataCache: DataCache

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false

    @State var selectedDate: Date? = .now
    @State var selectedMonth: Date = .now

    @State private var calendarHelper: CalendarHelper?

    var body: some View {
        NavigationStack {
            if let calendar = dataCache.studentCalendar, let calendarHelper = calendarHelper {
                MCalendarView(selectedDate: $selectedDate, selectedRange: nil) { config in
                    config.dayView(calendarHelper.buildDayView)
                }
            } else {
                Text("Unable to load calendar")
            }
        }
        .navigationTitle("Calendar")
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
            if !dataCache.studentCalendarLoaded {
                loadingMessage = .loadingCalendar
            } else if let calendar = dataCache.studentCalendar {
                calendarHelper = CalendarHelper(calendar: calendar.eventLists)

                print(dataCache.studentCalendar)
            }
        }
        .onChange(of: dataCache.studentCalendarLoaded) {
            loadingMessage = dataCache.studentCalendarLoaded ? .empty : .loadingCalendar

            if dataCache.studentCalendarLoaded, let calendar = dataCache.studentCalendar {
                calendarHelper = CalendarHelper(calendar: calendar.eventLists)

                print(dataCache.studentCalendar)
            }
        }
        .onChange(of: refresh) {
            do {
                try dataCache.reloadStudentCalendar(client: client, force: true)
            } catch {
                print("error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
