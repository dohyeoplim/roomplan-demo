//
//  ContentView.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import SwiftUI

//enum Route: Hashable {
//    case scan
//}

struct ContentView: View {
    //    @State private var path = NavigationPath()
    @State private var showScanner = false
    
    var body: some View {
        NavigationStack {
            ScannedRoomListView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            showScanner = true
                        } label : {
                            Label("New Scan", systemImage: "plus.viewfinder")
                        }
                    }
                }
        }
        .fullScreenCover(isPresented: $showScanner) {
            ScannerView()
        }
    }
}

#Preview {
    ContentView()
}
