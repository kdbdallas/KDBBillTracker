//
//  CalendarView.swift
//  KDBBillTracker
//
//  Created by Dallas Brown on 4/9/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDateComponents: DateComponents
    let preselectedDates: Set<DateComponents>

    @State private var displayedMonth: Date = Date()

    @Environment(\.calendar) var calendar

    private struct CalendarDay: Identifiable, Hashable {
        let id: String
        let date: Date?
        
        init(index: Int, date: Date?) {
            self.date = date
            self.id = date.map { ISO8601DateFormatter().string(from: $0) } ?? "empty-\(index)"
        }
    }

    private var daysInMonth: [CalendarDay] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [CalendarDay] = []

        for i in 0..<leadingEmptyDays {
            days.append(CalendarDay(index: i, date: nil))
        }

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(CalendarDay(index: leadingEmptyDays + day - 1, date: date))
            }
        }

        let trailingEmptyDays = (7 - days.count % 7) % 7

        for i in 0..<trailingEmptyDays {
            days.append(CalendarDay(index: days.count + i, date: nil))
        }

        return days
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(for: displayedMonth))
                    .font(.headline)
                Spacer()
                Button(action: {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.bottom, 8)

            let weekdaySymbols = calendar.shortWeekdaySymbols

            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                }
            }

            let rows = daysInMonth.chunked(into: 7)

            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row) { calendarDay in
                        Group {
                            if let date = calendarDay.date {
                                let day = calendar.component(.day, from: date)
                                let comps = calendar.dateComponents([.calendar, .era, .year, .month, .day], from: date)
                                let isInCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                                let isPreselected = preselectedDates.contains(where: {
                                    $0.year == comps.year && $0.month == comps.month && $0.day == comps.day
                                })

                                Button(action: {
                                    if isPreselected {
                                        if isSelectedDate(comps) {
                                            selectedDateComponents = DateComponents() // Deselect
                                        } else {
                                            selectedDateComponents = comps // Select new
                                        }
                                    }
                                }) {
                                    GeometryReader { geometry in
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text("\(day)")
                                                    .frame(width: geometry.size.width, height: geometry.size.height) // Ensure the width and height match
                                                    .background(
                                                        Circle()
                                                            .fill(
                                                                isPreselected && isSelectedDate(comps) ? Color.red.opacity(0.5) :
                                                                isPreselected ? Color.blue.opacity(0.3) :
                                                                Color.clear
                                                            )
                                                    )
                                                    .foregroundColor(isInCurrentMonth ? .primary : .gray)
                                                Spacer()
                                            }

                                            // Indicator for the current day
                                            if calendar.isDate(date, inSameDayAs: Date()) {
                                                Rectangle()
                                                    .frame(width: 20, height: 2)
                                                    .foregroundColor(.green) // Color for the current day indicator
                                                    .padding(.top, 2)
                                                    .frame(maxWidth: .infinity, alignment: .center) // Ensure it's centered
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                Text("")
                                    .frame(maxWidth: .infinity, minHeight: 40)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    private func isSelectedDate(_ components: DateComponents) -> Bool {
        selectedDateComponents.year == components.year &&
        selectedDateComponents.month == components.month &&
        selectedDateComponents.day == components.day
    }
}

// Chunk helper
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = DateComponents()

    CalendarView(
        selectedDateComponents: $selectedDate,
        preselectedDates: [
            DateComponents(year: 2025, month: 4, day: 9),
            DateComponents(year: 2025, month: 4, day: 15)
        ]
    )
}
