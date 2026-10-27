//
//  Toaster.swift
//  NotchKu
//

import Foundation

// kabar singkat yang tampil beberapa detik di kiri kanan notch
class Toaster: ObservableObject {
    static let shared = Toaster()

    struct Toast: Equatable {
        let id = UUID()
        let icon: String
        let text: String
    }

    @Published private(set) var current: Toast?

    func show(_ icon: String, _ text: String, for seconds: TimeInterval = 3) {
        DispatchQueue.main.async {
            let toast = Toast(icon: icon, text: text)
            self.current = toast
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                if self.current == toast { self.current = nil }
            }
        }
    }
}
