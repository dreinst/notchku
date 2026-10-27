//
//  TrayDrop+DropItem.swift
//  TrayDrop
//
//  Created by 秋星桥 on 2024/7/8.
//

import Cocoa
import CoreTransferable
import Foundation
import QuickLook
import UniformTypeIdentifiers

extension TrayDrop {
    struct DropItem: Identifiable, Codable, Equatable, Hashable {
        let id: UUID

        let fileName: String
        let size: Int

        let copiedDate: Date
        let workspacePreviewImageData: Data
        // diisi untuk screenshot: ke folder ini berkasnya dikembalikan setelah masa simpan habis
        var returnTo: URL?

        init(url: URL, move: Bool = false) throws {
            assert(!Thread.isMainThread)

            id = UUID()
            fileName = url.lastPathComponent

            size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            copiedDate = Date()
            workspacePreviewImageData = url.snapshotPreview().pngRepresentation

            try FileManager.default.createDirectory(
                at: storageURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if move {
                try FileManager.default.moveItem(at: url, to: storageURL)
                returnTo = url.deletingLastPathComponent()
            } else {
                try FileManager.default.copyItem(at: url, to: storageURL)
            }
        }
    }
}

extension TrayDrop.DropItem: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        let exportingBehavior: @Sendable (TrayDrop.DropItem) async throws -> SentTransferredFile = { input in
            let tempDir = temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let newPath = tempDir.appendingPathComponent(input.fileName)
            try FileManager.default.copyItem(
                at: input.storageURL,
                to: newPath
            )
            return .init(newPath, allowAccessingOriginalFile: true)
        }
        let importingBehavior: @Sendable (ReceivedTransferredFile) async throws -> TrayDrop.DropItem = { _ in
            fatalError()
        }
        return FileRepresentation(
            contentType: .data,
            shouldAttemptToOpenInPlace: true,
            exporting: exportingBehavior,
            importing: importingBehavior
        )
    }
}

extension TrayDrop.DropItem {
    static let mainDir = "CopiedItems"

    var storageURL: URL {
        documentsDirectory
            .appendingPathComponent(Self.mainDir)
            .appendingPathComponent(id.uuidString)
            .appendingPathComponent(fileName)
    }

    var workspacePreviewImage: NSImage {
        .init(data: workspacePreviewImageData) ?? .init()
    }

    var shouldClean: Bool {
        if !FileManager.default.fileExists(atPath: storageURL.path) { return true }
        let keepInterval = TrayDrop.shared.keepInterval
        guard keepInterval > 0 else { return true } // avoid non-reasonable value deleting user's files
        if Date().timeIntervalSince(copiedDate) > TrayDrop.shared.keepInterval { return true }
        return false
    }
}
