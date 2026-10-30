import Cocoa
import Combine
import Foundation
import LaunchAtLogin
import SwiftUI

class NotchViewModel: NSObject, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    let inset: CGFloat

    init(inset: CGFloat = -4) {
        self.inset = inset
        super.init()
        setupCancellables()
    }

    deinit {
        destroy()
    }

    // gerak singkat tanpa pantulan, cukup untuk menunjukkan notch membuka dan menutup
    let animation: Animation = .easeOut(duration: 0.2)
    let notchOpenedSize: CGSize = .init(width: 820, height: 170)
    let dropDetectorRange: CGFloat = 32

    enum Status: String, Codable, Hashable, Equatable {
        case closed
        case opened
        case popping
    }

    enum OpenReason: String, Codable, Hashable, Equatable {
        case click
        case hover
        case drag
        case boot
        case screenshot
        case unknown
    }

    enum ContentType: Int, Codable, Hashable, Equatable {
        case normal
        case menu
        case settings
    }

    var notchOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - notchOpenedSize.height,
            width: notchOpenedSize.width,
            height: notchOpenedSize.height
        )
    }

    var headlineOpenedRect: CGRect {
        .init(
            x: screenRect.origin.x + (screenRect.width - notchOpenedSize.width) / 2,
            y: screenRect.origin.y + screenRect.height - deviceNotchRect.height,
            width: notchOpenedSize.width,
            height: deviceNotchRect.height
        )
    }

    // area pemicu hover: separuh lebar notch di tengah, bagian atasnya saja,
    // supaya kursor yang lewat ke menu bar di samping notch tidak ikut membuka
    var hoverTriggerRect: CGRect {
        let width = deviceNotchRect.width / 2
        let height = deviceNotchRect.height * 0.6
        return .init(
            x: deviceNotchRect.midX - width / 2,
            y: deviceNotchRect.maxY - height,
            width: width,
            height: height
        )
    }

    @Published private(set) var status: Status = .closed
    @Published var openReason: OpenReason = .unknown
    @Published var contentType: ContentType = .normal

    @Published var spacing: CGFloat = 16
    @Published var cornerRadius: CGFloat = 16
    @Published var deviceNotchRect: CGRect = .zero
    @Published var screenRect: CGRect = .zero
    @Published var optionKeyPressed: Bool = false
    @Published var notchVisible: Bool = true

    @PublishedPersist(key: "selectedLanguage", defaultValue: .system)
    var selectedLanguage: Language

    @PublishedPersist(key: "hapticFeedback", defaultValue: true)
    var hapticFeedback: Bool

    let hapticSender = PassthroughSubject<Void, Never>()

    func notchOpen(_ reason: OpenReason) {
        openReason = reason
        status = .opened
        contentType = .normal
        // hover tidak merebut fokus dari app yang sedang dipakai
        if reason != .hover { NSApp.activate(ignoringOtherApps: true) }
    }

    // buka tanpa merebut fokus, tutup sendiri kalau kursor tidak di atas notch
    func notchPeek(_ reason: OpenReason, for seconds: TimeInterval = 4) {
        guard status != .opened else { return }
        openReason = reason
        status = .opened
        contentType = .normal
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
                guard let self, status == .opened, openReason == reason,
                  !notchOpenedRect.contains(NSEvent.mouseLocation)
            else { return }
            notchClose()
        }
    }

    func notchClose() {
        openReason = .unknown
        status = .closed
        contentType = .normal
    }

    func showSettings() {
        contentType = .settings
    }

    func notchPop() {
        openReason = .unknown
        status = .popping
    }
}
