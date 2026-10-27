//
//  FocusTimer.swift
//  NotchKu
//

import AppKit
import Foundation

class FocusTimer: ObservableObject {
    static let shared = FocusTimer()

    @Published private(set) var endDate: Date?
    @Published private(set) var remaining: TimeInterval = 0

    private var timer: Timer?

    var running: Bool { endDate != nil }

    var label: String {
        let s = Int(remaining.rounded(.up))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    func start(minutes: Int) {
        endDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        tick()
        timer?.invalidate()
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        remaining = 0
    }

    private func tick() {
        guard let endDate else { return }
        remaining = max(0, endDate.timeIntervalSinceNow)
        guard remaining == 0 else { return }
        stop()
        NSSound(named: "Glass")?.play()
        Toaster.shared.show("checkmark.circle.fill", "Waktu fokus selesai", for: 6)
    }
}
