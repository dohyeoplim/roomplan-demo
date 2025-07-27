//
//  ScannerView.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    var roomController = RoomPlanController.instance
    
    @State private var isScanning = true
    @State private var isProcessing = false
    @State private var savedURL: URL?
    @State private var showPreview = false
    
    var body: some View {
        ZStack {
            RoomCaptureViewRepresentable()
                .onAppear {
                    roomController.finalResult = nil
                    roomController.startSession()
                    isScanning = true
                }
            
            VStack {
                Spacer()
                if isScanning {
                    Button("Done") {
                        roomController.stopSession()
                        isScanning = false
                        isProcessing = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            if roomController.finalResult != nil {
                                isProcessing = false
                            } else {
                                waitForFinalResult()
                            }
                        }
                    }
                    .scannerButtonStyle()
                } else if isProcessing {
                    ProgressView("Processing...")
                        .padding()
                        .foregroundStyle(.black)
                        .background(Color.white.opacity(0.85))
                        .cornerRadius(8)
                } else {
                    Button("Save") {
                        if let _ = roomController.saveFinalResultToAppStorage() {
                            dismiss()
                        } else {
                            print("Failed to save room")
                        }
                    }
                    .scannerButtonStyle()
                }
            }
            .padding(.bottom, 10)
        }
        .sheet(isPresented: $showPreview) {
            if let url = savedURL {
                QuickLookPreview(url: url)
            }
        }
    }
    
    private func waitForFinalResult() {
        Task {
            for _ in 0..<10 {
                try? await Task.sleep(nanoseconds: 300_000_000)
                if roomController.finalResult != nil {
                    isProcessing = false
                    break
                }
            }
        }
    }
}

private extension Button {
    func scannerButtonStyle() -> some View {
        self
            .foregroundStyle(.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.85))
            .cornerRadius(100)
    }
}

#Preview {
    ZStack {
        VStack(spacing: 20) {
            ProgressView("Processing...")
                .padding()
                .foregroundStyle(.black)
                .background(Color.white.opacity(0.85))
                .cornerRadius(8)
            
            Button("Save") { }
                .scannerButtonStyle()
        }
    }
    .ignoresSafeArea(.all)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray.opacity(0.8))
}
