//
//  HabitsViewController.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/25/25.
//

import UIKit

class HabitsViewController: UIViewController {

    enum Filter {
        case today
        case all
    }

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterControl: UISegmentedControl!

    // MARK: - Data
    private let store = HabitStore.shared
    private var currentFilter: Filter = .today {
        didSet { tableView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Habits"
        view.backgroundColor = .systemBackground

        setupFilterControl()
        setupTableView()
    }

    // MARK: - UI Setup

    private func setupFilterControl() {
        filterControl.selectedSegmentIndex = 0
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        // Prototype cell in storyboard is already registered by identifier "HabitCell"
    }

    // MARK: - Filtering

    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        currentFilter = (sender.selectedSegmentIndex == 0) ? .today : .all
    }

    private var filteredHabits: [Habit] {
        let sorted = store.habits.sorted { $0.name < $1.name }

        switch currentFilter {
        case .today:
            // only show habits not completed today
            return sorted.filter { !$0.isCompletedToday() }
        case .all:
            return sorted
        }
    }

    private func indexInStore(for indexPath: IndexPath) -> Int? {
        let habit = filteredHabits[indexPath.row]
        return store.habits.firstIndex(where: { $0.id == habit.id })
    }

    // MARK: - Stats Helpers

    private var totalHabits: Int {
        store.habits.count
    }

    private var completedTodayCount: Int {
        store.habits.filter { $0.isCompletedToday() }.count
    }

    private var remainingTodayCount: Int {
        max(0, totalHabits - completedTodayCount)
    }

    private var bestStreak: Int {
        store.habits.map { $0.currentStreak() }.max() ?? 0
    }

    private func currentStats() -> HabitStats {
        return HabitStats(
            totalHabits: totalHabits,
            completedToday: completedTodayCount,
            remainingToday: remainingTodayCount,
            bestStreak: bestStreak
        )
    }

    // MARK: - Actions

    @IBAction func addHabitTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addVC = storyboard.instantiateViewController(
            withIdentifier: "AddHabitViewController"
        ) as? AddHabitViewController else {
            return
        }

        addVC.onSave = { [weak self] habit in
            self?.store.add(habit)
            self?.tableView.reloadData()
        }

        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }

    @IBAction func statsTapped(_ sender: UIBarButtonItem) {
        let stats = currentStats()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let statsVC = storyboard.instantiateViewController(
            withIdentifier: "StatsViewController"
        ) as? StatsViewController else {
            return
        }

        statsVC.stats = stats
        navigationController?.pushViewController(statsVC, animated: true)
    }
}

// MARK: - Table View

extension HabitsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return filteredHabits.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HabitCell",
            for: indexPath
        ) as? HabitCell else {
            return UITableViewCell()
        }

        let habit = filteredHabits[indexPath.row]
        cell.configure(with: habit)
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let storeIndex = indexInStore(for: indexPath) else { return }

        store.toggleCompletionToday(for: storeIndex)
        tableView.reloadData() // filter may hide row in Today mode
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
           let storeIndex = indexInStore(for: indexPath) {
            store.delete(at: storeIndex)
            tableView.reloadData()
        }
    }
}
