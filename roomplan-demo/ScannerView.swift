//
//  ScannerView.swift
//  roomplan-demo
//
//  Created by dohyeoplim on 7/28/25.
//

import SwiftUI

struct ScannerView: View {
    var roomController = RoomPlanController.instance
    @State private var doneScanning : Bool = false
    
    var body: some View {
        ZStack{
            RoomCaptureViewRepresentable()
                .onAppear(perform: {
                    roomController.startSession()
                })
            
            VStack{
                Spacer()
                if doneScanning == false {
                    Button(action: {
                        roomController.stopSession()
                        self.doneScanning = true
                    }, label: {
                        Text("Done")
                    })
                    .foregroundStyle(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .opacity(0.8)
                    .cornerRadius(100)
                }
              
            }
            .padding(.bottom,10)
        }
    }
}


#Preview {
    ScannerView()
}
