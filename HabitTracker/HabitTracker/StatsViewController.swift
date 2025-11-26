//
//  StatsViewController.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/26/25.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var bestStreakLabel: UILabel!

    var stats: HabitStats!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Stats"
        updateUI()
    }

    private func updateUI() {
        guard let stats = stats else { return }

        totalLabel.text = "Total habits: \(stats.totalHabits)"
        completedLabel.text = "Completed today: \(stats.completedToday)"
        remainingLabel.text = "Remaining today: \(stats.remainingToday)"
        bestStreakLabel.text = "Best streak: \(stats.bestStreak) days"
    }
}

