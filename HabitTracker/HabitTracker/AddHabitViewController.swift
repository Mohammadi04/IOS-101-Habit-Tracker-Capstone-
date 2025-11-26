//
//  AddHabitViewController.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/26/25.
//

import UIKit
import UserNotifications

class AddHabitViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var iconTextField: UITextField!
    @IBOutlet weak var reminderSwitch: UISwitch!
    @IBOutlet weak var reminderTimePicker: UIDatePicker!

    var onSave: ((Habit) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Habit"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        reminderTimePicker.datePickerMode = .time
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }

        let icon = iconTextField.text?.isEmpty == false ? iconTextField.text! : "✅"

        var reminderEnabled = false
        var hour: Int? = nil
        var minute: Int? = nil

        if reminderSwitch.isOn {
            reminderEnabled = true
            let calendar = Calendar.current
            let date = reminderTimePicker.date
            hour = calendar.component(.hour, from: date)
            minute = calendar.component(.minute, from: date)

            requestNotificationPermissionIfNeeded()
        }

        let habit = Habit(
            name: name,
            icon: icon,
            reminderEnabled: reminderEnabled,
            reminderHour: hour,
            reminderMinute: minute
        )

        onSave?(habit)
        dismiss(animated: true)
    }

    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
            }
        }
    }
}

