//
//  ScanStorageManager.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import Foundation
import RoomPlan
import UIKit
import SceneKit

final class ScanStorageManager: ObservableObject {
    static let shared = ScanStorageManager()
    
    @Published var savedRooms: [ScannedRoomModel] = []
    
    private let metadataFile = ScannedRoomModel.folderURL.appendingPathComponent("scans.json")
    
    private init() {
        load()
    }
    
    func save(room: CapturedRoom) {
        let id = UUID()
        let name = "Room_\(id.uuidString.prefix(6))"
        let metadata = ScannedRoomModel(id: id, fileName: name, timestamp: Date())
        
        let folder = ScannedRoomModel.folderURL
        let usdzURL = folder.appendingPathComponent(name + ".usdz")
        let jsonURL = folder.appendingPathComponent(name + ".json")
        let thumbnailURL = folder.appendingPathComponent(name + ".png")
        
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            
            try room.export(to: usdzURL, exportOptions: .parametric)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(room)
            try jsonData.write(to: jsonURL)
            
            if let thumbnail = renderThumbnail(from: usdzURL),
               let pngData = thumbnail.pngData() {
                try pngData.write(to: thumbnailURL)
            } else {
                print("Failed to render or write PNG")
            }
            
            savedRooms.insert(metadata, at: 0)
            saveMetadata()
        } catch {
            print("Error saving room:", error)
        }
    }
    
    private func saveMetadata() {
        do {
            let data = try JSONEncoder().encode(savedRooms)
            try data.write(to: metadataFile)
        } catch {
            print("Failed to save metadata:", error)
        }
    }
    
    func saveAndReturnURL(room: CapturedRoom) -> URL? {
        save(room: room)
        return savedRooms.first?.usdzURL
    }
    
    // TODO: Unstable
    private func load() {
        do {
            let data = try Data(contentsOf: metadataFile)
            savedRooms = try JSONDecoder().decode([ScannedRoomModel].self, from: data)
        } catch {
            savedRooms = []
        }
    }
}

extension ScanStorageManager {
    // TODO: Thunbnail is not rendering
    func renderThumbnail(from url: URL, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        guard let scene = try? SCNScene(url: url, options: nil) else { return nil }
        
        let scnView = SCNView(frame: CGRect(origin: .zero, size: size))
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.pointOfView = makeFitCamera(for: scene)
        scnView.isPlaying = true
        scnView.antialiasingMode = .multisampling4X
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        scnView.drawHierarchy(in: scnView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func makeFitCamera(for scene: SCNScene) -> SCNNode {
        let (boundingMin, boundingMax) = scene.rootNode.boundingBox
        let center = SCNVector3(
            (boundingMin.x + boundingMax.x) / 2,
            (boundingMin.y + boundingMax.y) / 2,
            (boundingMin.z + boundingMax.z) / 2
        )
        let size = SCNVector3(
            boundingMax.x - boundingMin.x,
            boundingMax.y - boundingMin.y,
            boundingMax.z - boundingMin.z
        )
        let largestDimension = Swift.max(size.x, size.y, size.z)
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(center.x, center.y, center.z + largestDimension * 2.5)
        return cameraNode
    }
    
    func delete(room: ScannedRoomModel) {
        let fileManager = FileManager.default
        
        try? fileManager.removeItem(at: room.usdzURL)
        
        let jsonURL = ScannedRoomModel.folderURL.appendingPathComponent(room.fileName + ".json")
        try? fileManager.removeItem(at: jsonURL)
        
        let thumbnailURL = ScannedRoomModel.folderURL.appendingPathComponent(room.fileName + ".png")
        try? fileManager.removeItem(at: thumbnailURL)
        
        savedRooms.removeAll { $0.id == room.id }
        saveMetadata()
    }
}
