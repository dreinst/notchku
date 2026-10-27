//
//  Spotify.swift
//  NotchKu
//

import AppKit
import Foundation

class Spotify: ObservableObject {
    static let shared = Spotify()

    @Published private(set) var playing = false
    @Published private(set) var title = ""
    @Published private(set) var artist = ""
    @Published private(set) var artwork: NSImage?

    private let bundleID = "com.spotify.client"
    private var trackID = ""

    func start() {
        DistributedNotificationCenter.default().addObserver(
            forName: .init("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.update(note.userInfo ?? [:])
        }
        refresh()
    }

    var isRunning: Bool {
        !NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
    }

    func playPause() { run("playpause") }
    func next() { run("next track") }
    func previous() { run("previous track") }

    // keadaan awal kalau Spotify sudah diputar sebelum NotchKu jalan
    private func refresh() {
        guard isRunning,
              let out = run("""
              if player state is stopped then return ""
              set t to current track
              return (player state as string) & "\\n" & name of t & "\\n" & artist of t & "\\n" & id of t
              """), !out.isEmpty
        else { return }
        let parts = out.components(separatedBy: "\n")
        guard parts.count == 4 else { return }
        update(["Player State": parts[0] == "playing" ? "Playing" : "Paused",
                "Name": parts[1], "Artist": parts[2], "Track ID": parts[3]])
    }

    private func update(_ info: [AnyHashable: Any]) {
        playing = info["Player State"] as? String == "Playing"
        title = info["Name"] as? String ?? title
        artist = info["Artist"] as? String ?? artist
        let id = info["Track ID"] as? String ?? trackID
        guard id != trackID else { return }
        trackID = id
        loadArtwork()
    }

    private func loadArtwork() {
        DispatchQueue.global().async { [weak self] in
            guard let self,
                  let link = run("return artwork url of current track"),
                  let url = URL(string: link),
                  let data = try? Data(contentsOf: url)
            else { return }
            let image = NSImage(data: data)
            DispatchQueue.main.async { self.artwork = image }
        }
    }

    @discardableResult
    private func run(_ body: String) -> String? {
        // jangan sampai perintah AppleScript malah membuka Spotify
        guard isRunning else { return nil }
        let script = NSAppleScript(source: "tell application id \"\(bundleID)\"\n\(body)\nend tell")
        var error: NSDictionary?
        return script?.executeAndReturnError(&error).stringValue
    }
}
