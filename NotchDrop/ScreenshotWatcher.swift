//
//  ScreenshotWatcher.swift
//  NotchKu
//

import Combine
import Foundation

class ScreenshotWatcher {
    static let shared = ScreenshotWatcher()

    let captured = PassthroughSubject<Void, Never>()

    private let queue = DispatchQueue(label: "ScreenshotWatcher")
    private var source: DispatchSourceFileSystemObject?
    private var seen = Set<String>()

    // ikut lokasi simpan screenshot di macOS, bawaannya Desktop
    let folder: URL = {
        let path = UserDefaults(suiteName: "com.apple.screencapture")?.string(forKey: "location")
            ?? "~/Desktop"
        return URL(fileURLWithPath: (path as NSString).expandingTildeInPath, isDirectory: true)
    }()

    private init() {}

    func start() {
        let fd = open(folder.path, O_EVTONLY)
        guard fd >= 0 else { return }
        seen = Set(fileNames())
        let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: .write, queue: queue)
        source.setEventHandler { [weak self] in self?.scan() }
        source.setCancelHandler { close(fd) }
        source.resume()
        self.source = source
    }

    // berkas yang dikembalikan dari tray jangan dianggap screenshot baru
    func ignore(_ name: String) {
        queue.sync { _ = seen.insert(name) }
    }

    private func fileNames() -> [String] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        // macOS menulis dulu ke berkas tersembunyi lalu mengganti namanya
        return names.filter { !$0.hasPrefix(".") }
    }

    private func scan() {
        let fresh = fileNames().filter { !seen.contains($0) }
        guard !fresh.isEmpty else { return }
        seen.formUnion(fresh)
        let media = ["png", "jpg", "jpeg", "heic", "tiff", "mov", "mp4"]
        let urls = fresh
            .map { folder.appendingPathComponent($0) }
            .filter { media.contains($0.pathExtension.lowercased()) }
        guard !urls.isEmpty else { return }
        TrayDrop.shared.add(urls, move: true)
        DispatchQueue.main.async { self.captured.send() }
    }
}
