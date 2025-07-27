//
//  ScannedRoomModel.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import Foundation

struct ScannedRoomModel: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let timestamp: Date

    var usdzURL: URL {
        Self.folderURL.appendingPathComponent(fileName + ".usdz")
    }

    var thumbnailURL: URL {
        Self.folderURL.appendingPathComponent(fileName + ".png")
    }

    static var folderURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SavedRooms", isDirectory: true)
    }
}
