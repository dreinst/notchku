//
//  PlaudWatcher.swift
//  NotchKu
//

import AppKit
import Foundation
import Security
import WebKit

// Plaud Note merekam lewat HP, jadi Mac baru tahu setelah rekamannya masuk ke akun Plaud.
// Daftar rekaman diambil dari API yang sama dengan Plaud.app (/file/simple/web).
class PlaudWatcher: ObservableObject {
    static let shared = PlaudWatcher()

    @Published private(set) var connected = false

    private var baseURL = UserDefaults.standard.string(forKey: "plaudBaseURL") ?? "https://api.plaud.ai"
    private var lastSeenID = UserDefaults.standard.string(forKey: "plaudLastSeenID")
    private var timer: Timer?
    private var loginWindow: NSWindow?
    private var loginTimer: Timer?

    func start() {
        connected = token != nil
        poll()
        timer = .scheduledTimer(withTimeInterval: 120, repeats: true) { [weak self] _ in self?.poll() }
    }

    // MARK: login lewat web.plaud.ai, token diambil dari localStorage halaman itu

    func connect() {
        if let loginWindow { loginWindow.makeKeyAndOrderFront(nil); return }
        let web = WKWebView(frame: .init(x: 0, y: 0, width: 900, height: 700))
        web.load(URLRequest(url: URL(string: "https://web.plaud.ai")!))
        let window = NSWindow(
            contentRect: web.frame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Hubungkan Plaud"
        window.contentView = web
        window.isReleasedWhenClosed = false
        window.center()
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        loginWindow = window

        loginTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self, weak web] _ in
            guard let self, let web else { return }
            if !window.isVisible { finishLogin(); return }
            let js = "localStorage.getItem('tokenstr') || Object.values(localStorage).find(v => /^bearer\\s/i.test(v)) || ''"
            web.evaluateJavaScript(js) { result, _ in
                guard let value = result as? String, !value.isEmpty else { return }
                self.token = value
                self.lastSeenID = nil
                self.connected = true
                self.finishLogin()
                Toaster.shared.show("waveform.badge.mic", "Plaud tersambung")
                self.poll()
            }
        }
    }

    func disconnect() {
        token = nil
        connected = false
    }

    private func finishLogin() {
        loginTimer?.invalidate()
        loginTimer = nil
        loginWindow?.close()
        loginWindow = nil
    }

    // MARK: cek rekaman baru

    private func poll(retry: Bool = true) {
        guard let token else { return }
        let auth = token.lowercased().hasPrefix("bearer") ? token : "bearer \(token)"
        let path = "/file/simple/web?limit=5&skip=0&is_trash=2&sort_by=start_time&is_desc=true"
        guard let url = URL(string: baseURL + path) else { return }
        var request = URLRequest(url: url)
        request.setValue(auth, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            guard let self,
                  let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            DispatchQueue.main.async {
                self.handle(json, httpStatus: (response as? HTTPURLResponse)?.statusCode ?? 0, retry: retry)
            }
        }.resume()
    }

    private func handle(_ json: [String: Any], httpStatus: Int, retry: Bool) {
        let status = json["status"] as? Int ?? 0
        if status == -302,
           let api = (json["data"] as? [String: Any])?["domains"] as? [String: Any],
           let domain = api["api"] as? String, !domain.isEmpty
        {
            baseURL = domain.hasPrefix("http") ? domain : "https://\(domain)"
            UserDefaults.standard.set(baseURL, forKey: "plaudBaseURL")
            if retry { poll(retry: false) }
            return
        }
        if httpStatus == 401 || status == -419 || status == -420 {
            disconnect()
            Toaster.shared.show("exclamationmark.triangle", "Login Plaud kedaluwarsa", for: 5)
            return
        }
        guard let files = json["data_file_list"] as? [[String: Any]], let newest = files.first,
              let newestID = newest["id"] as? String
        else { return }

        // pertama kali cukup dicatat, supaya rekaman lama tidak dikabarkan
        guard let lastSeenID else {
            remember(newestID)
            return
        }
        let fresh = files.prefix { ($0["id"] as? String) != lastSeenID }
        remember(newestID)
        guard let file = fresh.first else { return }

        var text = fresh.count > 1 ? "\(fresh.count) rekaman Plaud baru" : "Rekaman Plaud baru"
        if fresh.count == 1, let ms = file["duration"] as? Double, ms > 0 {
            text += ", \(Int((ms / 60000).rounded(.up))) menit"
        }
        Toaster.shared.show("waveform.badge.mic", text, for: 6)
    }

    private func remember(_ id: String) {
        lastSeenID = id
        UserDefaults.standard.set(id, forKey: "plaudLastSeenID")
    }

    // MARK: token disimpan di Keychain

    private let service = "dreinst.notchku.plaud"

    private var token: String? {
        get {
            var item: CFTypeRef?
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecReturnData as String: true,
            ]
            guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
                  let data = item as? Data
            else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
            ]
            SecItemDelete(query as CFDictionary)
            guard let newValue else { return }
            var add = query
            add[kSecValueData as String] = Data(newValue.utf8)
            SecItemAdd(add as CFDictionary, nil)
        }
    }
}
