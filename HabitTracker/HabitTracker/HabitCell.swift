//
//  HabitCell.swift
//  HabitTracker
//
//  Created by Tanzim Islam on 11/26/25.
//

import UIKit

class HabitCell: UITableViewCell {

    let iconLabel = UILabel()
    let nameLabel = UILabel()
    let streakLabel = UILabel()
    let todayLabel = UILabel()
    let progressView = UIProgressView(progressViewStyle: .default)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        streakLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        streakLabel.textColor = .secondaryLabel
        todayLabel.font = UIFont.systemFont(ofSize: 22)

        [iconLabel, nameLabel, streakLabel, todayLabel, progressView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconLabel.widthAnchor.constraint(equalToConstant: 34),

            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: todayLabel.leadingAnchor, constant: -8),

            streakLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            streakLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            streakLabel.trailingAnchor.constraint(lessThanOrEqualTo: todayLabel.leadingAnchor, constant: -8),

            progressView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 8),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 3),

            todayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            todayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with habit: Habit) {
        iconLabel.text = habit.icon
        nameLabel.text = habit.name

        let streak = habit.currentStreak()
        streakLabel.text = "Streak: \(streak)🔥"

        let rate = Float(habit.completionRateLast7Days())
        progressView.progress = rate

        todayLabel.text = habit.isCompletedToday() ? "✅" : "⭕️"
    }
}

