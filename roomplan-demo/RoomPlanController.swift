//
//  RoomPlanController.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import RoomPlan
import SwiftUI

class RoomPlanController: RoomCaptureViewDelegate {
    func encode(with coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Needed")
    }
    
    static var instance = RoomPlanController()
    var captureView  : RoomCaptureView
    var sessionConfig : RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    @Published var finalResult: CapturedRoom?
    
    init() {
        captureView = RoomCaptureView(frame: .zero)
        captureView.delegate = self
    }
    
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: (Error)?) -> Bool {
        return true
    }
    
    func captureView(didPresent processedResult: CapturedRoom, error: (Error)?) {
        DispatchQueue.main.async {
            self.finalResult = processedResult
        }
    }
    
    func startSession() {
        captureView.captureSession.run(configuration: sessionConfig)
    }
    
    func stopSession() {
        captureView.captureSession.stop()
    }
    
    func saveFinalResultToAppStorage() -> URL? {
        guard let room = finalResult else { return nil }

        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("SavedRooms", isDirectory: true)
        let usdzURL = folder.appendingPathComponent("Scan.usdz")
        let jsonURL = folder.appendingPathComponent("Scan.json")

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(room)
            try jsonData.write(to: jsonURL)

            try room.export(to: usdzURL, exportOptions: .parametric)
            return usdzURL
        } catch {
            return nil
        }
    }
}

struct RoomCaptureViewRepresentable : UIViewRepresentable {
    
    func makeUIView(context: Context) -> RoomCaptureView{
        return RoomPlanController.instance.captureView
    }
    
    func updateUIView(_ uiView: RoomCaptureView, context: Context) {
        
    }
}
