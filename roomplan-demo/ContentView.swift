//
//  ContentView.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import SwiftUI

enum Route: Hashable {
    case scan
}

struct ContentView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Start") {
                    path.append(Route.scan)
                }
            }
            .navigationTitle("Room Scan Demo")
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .scan:
                    ScannerView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
