//
//  CalendarHelper.swift
//  PortalBook
//
//  Created by Peter Duanmu on 8/19/24.
//

import SwiftUI
import MijickCalendarView
import StudentVue

class CalendarHelper {
    private var events: [Date: StudentVueApi.CalendarEventList]

    public init(calendar: [StudentVueApi.CalendarEventList]) {
        self.events = [:]

        for event in calendar {
            events[event.date] = event
        }
    }

    public func buildDayView(_ date: Date,
                             _ isCurrentMonth: Bool,
                             selectedDate: Binding<Date?>?,
                             range: Binding<MDateRange?>?) -> BuildDayView {
        return BuildDayView(date: date,
                            color: getDateColor(date),
                            isCurrentMonth: isCurrentMonth,
                            selectedDate: selectedDate,
                            selectedRange: nil)
    }

    public func getDateColor(_ date: Date) -> Color? {
        let hasSavedEvents = events.first(where: { Calendar.current.isDate($0.key, inSameDayAs: date) }) != nil
        return hasSavedEvents ? .gray : nil
    }
}

extension CalendarHelper {
    struct Event: Equatable, Hashable {
        let name: String
        let color: Color
    }

    struct BuildDayView: DayView {
        let date: Date
        let color: Color?
        let isCurrentMonth: Bool
        let selectedDate: Binding<Date?>?
        let selectedRange: Binding<MDateRange?>?

        func createDayLabel() -> AnyView {
            ZStack {
                createBackgroundView()
                createDayLabelText()
            }
            .erased() // cast to AnyView
        }

        func createBackgroundView() -> some View {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.orange)
        }

        func createDayLabelText() -> some View {
            Text(getStringFromDay(format: "d"))
                .font(.system(size: 17))
                .foregroundColor(.white)
        }
    }
}
