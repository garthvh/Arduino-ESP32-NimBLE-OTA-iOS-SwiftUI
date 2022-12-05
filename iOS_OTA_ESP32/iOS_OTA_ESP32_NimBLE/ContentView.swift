//
//  ContentView.swift
//  Created by Garth Vander Houwen on 12/4/22
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var ble : BLEConnection
    var body: some View{
        VStack (alignment: .center) {
            Text("Meshtastic Flasher Wireless Firmware Update Tool for ESP32 Devices")
                .font(.title)
                .tint(.accentColor)
                .multilineTextAlignment(.center)
                .padding(.top, 50)
                .padding()
            HStack{
                if !ble.connected {
                    Button(action: {
                            ble.startScanning()
                        }){
                            Label("Connect", systemImage: "antenna.radiowaves.left.and.right")
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(.blue, lineWidth: 2))
                                .accentColor(.blue)
                    }
                } else {
                    VStack {
                        Text("Connected Meshtastic Device:")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .tint(.green)
                            .padding(.top)
                        Text(ble.name)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .tint(.green)
                            .padding(.bottom)
                        
                        if !ble.transferOngoing {
                            
                            Button(action: {
                                ble.disconnect()
                            }){
                                Label("Disconnect", systemImage: "antenna.radiowaves.left.and.right.slash")
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                        .stroke(.red, lineWidth: 2))
                                    .accentColor(.red)
                            }
                        }
                    }
                }
            }
           
            if ble.connected && ble.transferOngoing {
                VStack {
                
                    Text("Transfer speed : \(ble.kBPerSecond, specifier: "%.1f") kB/s")
                    Text("Elapsed time   : \(ble.elapsedTime, specifier: "%.1f") s")
                        .padding(.bottom)
                    ProgressView("Uploading Firmware", value: (ble.transferProgress / 100))
                        .accentColor(.green)
                        .padding()
                }
            }
            
            HStack{
                if ble.connected && !ble.transferOngoing {
                    Button(action: {
                        ble.sendFile(filename: "firmware-tbeam-2.0.6-update", fileEnding: ".bin")
                    }){
                        Text("Update Firmware")
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(.blue, lineWidth: 2))
                            .tint(.blue)
                    }
                    .padding()
                }
            }
        }
        .padding()
        Spacer()
    }
}
