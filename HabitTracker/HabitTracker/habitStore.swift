//
//  habitStore.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/25/25.
//

import Foundation
import UserNotifications

class HabitStore {
    static let shared = HabitStore()

    private let storageKey = "habits"
    private(set) var habits: [Habit] = []

    private init() {
        load()
    }

    // MARK: - CRUD

    func add(_ habit: Habit) {
        habits.append(habit)
        save()
        scheduleNotification(for: habit)
    }

    func update(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            save()
            cancelNotification(for: habit)
            scheduleNotification(for: habit)
        }
    }

    func delete(at index: Int) {
        let habit = habits[index]
        cancelNotification(for: habit)
        habits.remove(at: index)
        save()
    }

    func toggleCompletionToday(for index: Int) {
        var habit = habits[index]
        let calendar = Calendar.current

        if let i = habit.completions.firstIndex(where: { calendar.isDateInToday($0) }) {
            habit.completions.remove(at: i)
        } else {
            habit.completions.append(Date())
        }

        habits[index] = habit
        save()
    }

    // MARK: - Persistence

    private func save() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(habits) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? decoder.decode([Habit].self, from: data) else { return }
        habits = decoded
    }

    // MARK: - Notifications (stretch)

    private func scheduleNotification(for habit: Habit) {
        guard habit.reminderEnabled,
              let hour = habit.reminderHour,
              let minute = habit.reminderMinute else { return }

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Don't forget: \(habit.name)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: habit.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    private func cancelNotification(for habit: Habit) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
    }
}
