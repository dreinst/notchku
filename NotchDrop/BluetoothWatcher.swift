//
//  BluetoothWatcher.swift
//  NotchKu
//

import Foundation
import IOBluetooth

class BluetoothWatcher: NSObject {
    static let shared = BluetoothWatcher()

    private var notifications: [IOBluetoothUserNotification] = []
    // alamat perangkat yang sudah tersambung sebelum app jalan, notifikasinya tidak perlu ditampilkan
    private var alreadyConnected: Set<String> = []
    // alamat perangkat yang dianggap tersambung, hanya ini yang dapat toast saat terputus
    private var visible: Set<String> = []

    func start() {
        let paired = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] ?? []
        alreadyConnected = Set(paired.filter { $0.isConnected() }.compactMap(\.addressString))
        visible = alreadyConnected
        if let n = IOBluetoothDevice.register(forConnectNotifications: self, selector: #selector(connected(_:device:))) {
            notifications.append(n)
        }
    }

    @objc private func connected(_: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        if let n = device.register(forDisconnectNotification: self, selector: #selector(disconnected(_:device:))) {
            notifications.append(n)
        }
        // macOS melaporkan ulang perangkat yang sudah tersambung saat pendaftaran, abaikan sekali
        if let address = device.addressString, alreadyConnected.remove(address) != nil { return }
        // iPhone dan Watch sering tersambung sekejap untuk Handoff, tampilkan hanya kalau masih tersambung
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self, device.isConnected() else { return }
            if let address = device.addressString { self.visible.insert(address) }
            Toaster.shared.show(self.icon(device), "\(device.name ?? "Bluetooth") tersambung")
        }
    }

    @objc private func disconnected(_ n: IOBluetoothUserNotification, device: IOBluetoothDevice) {
        n.unregister()
        notifications.removeAll { $0 === n }
        guard let address = device.addressString else { return }
        alreadyConnected.remove(address)
        guard visible.remove(address) != nil else { return }
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
