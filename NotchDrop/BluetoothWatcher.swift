//
//  BluetoothWatcher.swift
//  NotchKu
//

import Foundation
import IOBluetooth

class BluetoothWatcher: NSObject {
    static let shared = BluetoothWatcher()

    private var started = Date()
    private var notifications: [IOBluetoothUserNotification] = []

    func start() {
        started = Date()
        if let n = IOBluetoothDevice.register(forConnectNotifications: self, selector: #selector(connected(_:device:))) {
            notifications.append(n)
        }
    }

    @objc private func connected(_: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        if let n = device.register(forDisconnectNotification: self, selector: #selector(disconnected(_:device:))) {
            notifications.append(n)
        }
        // saat baru jalan macOS melaporkan semua perangkat yang sudah tersambung
        guard Date().timeIntervalSince(started) > 3 else { return }
        Toaster.shared.show(icon(device), "\(device.name ?? "Bluetooth") tersambung")
    }

    @objc private func disconnected(_ n: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        n.unregister()
        notifications.removeAll { $0 === n }
        Toaster.shared.show(icon(device), "\(device.name ?? "Bluetooth") terputus")
    }

    private func icon(_ device: IOBluetoothDevice) -> String {
        let name = (device.name ?? "").lowercased()
        if name.contains("airpods") { return "airpods" }
        if name.contains("keyboard") { return "keyboard" }
        if name.contains("mouse") || name.contains("trackpad") { return "computermouse" }
        if device.deviceClassMajor == kBluetoothDeviceClassMajorAudio { return "headphones" }
        return "dot.radiowaves.left.and.right"
    }
}
