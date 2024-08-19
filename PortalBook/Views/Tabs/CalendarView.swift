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
    var client: StudentVue

    @Binding var loadingMessage: LoadingMessages
    @Binding var errorMessage: String

    @State var refresh = false
    @State var calendar: StudentVueApi.StudentCalendar? {
        didSet {
            if calendar == nil {
                refresh.toggle()
            }
        }
    }

    @State var selectedDate: Date? = .now
    @State var selectedMonth: Date = .now

    @State private var calendarHelper: CalendarHelper?

    var body: some View {
        NavigationStack {
            if let calendar = calendar, let calendarHelper = calendarHelper {
                MCalendarView(selectedDate: $selectedDate, selectedRange: nil) { config in
                    config.dayView(calendarHelper.buildDayView)
                }
            }
        }
        .navigationTitle("Calendar")
        .toolbar {
            ToolbarItem {
                Button {
                    calendar = nil
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear { calendar == nil ? calendar = nil : nil }
        .onChange(of: refresh) {
            Task {
                defer {
                    loadingMessage = .empty
                }

                loadingMessage = .loadingCalendar

                do {
                    calendar = try await client.api.getCalendar()

                    if let calendar = calendar {
                        calendarHelper = CalendarHelper(calendar: calendar.eventLists)
                    }
                    print(calendar)
                } catch {
                    print("error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

