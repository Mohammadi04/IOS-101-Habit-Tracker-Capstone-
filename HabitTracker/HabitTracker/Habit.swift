//
//  Habit.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/25/25.
//

import Foundation

struct Habit: Codable {
    let id: UUID
    var name: String
    var icon: String        // emoji like "💧"
    var completions: [Date] // days when the habit was done

    // Reminder settings (stretch)
    var reminderEnabled: Bool
    var reminderHour: Int?
    var reminderMinute: Int?

    init(name: String,
         icon: String,
         reminderEnabled: Bool = false,
         reminderHour: Int? = nil,
         reminderMinute: Int? = nil) {

        self.id = UUID()
        self.name = name
        self.icon = icon
        self.completions = []
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }

    // Is this habit completed today?
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return completions.contains { calendar.isDateInToday($0) }
    }

    // Completion rate for last 7 days (0.0 – 1.0)
    func completionRateLast7Days() -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var count = 0
        for offset in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: -offset, to: today) {
                if completions.contains(where: { calendar.isDate($0, inSameDayAs: day) }) {
                    count += 1
                }
            }
        }
        return Double(count) / 7.0
    }

    // Number of consecutive days (including today if done)
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0

        for offset in 0..<365 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { break }

            let done = completions.contains { calendar.isDate($0, inSameDayAs: day) }

            if done {
                streak += 1
            } else {
                if offset == 0 {
                    // today not done, but we still want past streak
                    continue
                } else {
                    break
                }
            }
        }

        return streak
    }
}
