//
//  ScannedRoomListView.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import SwiftUI
import SceneKit

struct ScannedRoomListView: View {
    @ObservedObject var manager = ScanStorageManager.shared
    @State private var selectedURL: URL?
    @State private var showPreview = false
    
    var body: some View {
        Group {
            if manager.savedRooms.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No scanned rooms yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(manager.savedRooms) { room in
                        Button {
                            selectedURL = room.usdzURL
                            showPreview = true
                        } label: {
                            HStack {
                                RoomThumbnailView(url: room.thumbnailURL)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                VStack(alignment: .leading) {
                                    Text(room.fileName)
                                        .fontWeight(.medium)
                                    Text(room.timestamp.formatted())
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                manager.delete(room: room)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Room Scans")
        .sheet(isPresented: $showPreview) {
            if let url = selectedURL {
                QuickLookPreview(url: url)
            }
        }
    }
}

struct RoomThumbnailView: View {
    let url: URL
    
    var body: some View {
        if let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            }
        }
    }
}
