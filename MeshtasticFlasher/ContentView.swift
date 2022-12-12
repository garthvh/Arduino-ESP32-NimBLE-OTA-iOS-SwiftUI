//
//  ContentView.swift
//  Created by Garth Vander Houwen on 12/4/22
//

import SwiftUI

struct FirmwareFile : Identifiable {
    let id = UUID()
    let name: String
    let value: String
}

struct ContentView: View {
    @EnvironmentObject var ble : BLEConnection
    @State var firmwareFiles: [FirmwareFile]
    @State var selectedFile: String = "tbeam"
    
    init () {
        var firmwares: [FirmwareFile]? = []
        let fileURLS = Bundle.main.urls(forResourcesWithExtension: ".bin", subdirectory: "")
        for val in fileURLS ?? [] {
            
            let name = val.relativeString
                .replacingOccurrences(of: "firmware-", with: "")
                .replacingOccurrences(of: "2.0.7.91ff7b9-update.bin", with: "")
                .replacingOccurrences(of: "-", with: " ")
            
            let value = val.relativeString
                .replacingOccurrences(of: ".bin", with: "")
            
            let varFile = FirmwareFile(name: name, value: value)
            firmwares?.append(varFile)
        }

        let sortedFirmwares = firmwares?.sorted {
            $0.name < $1.name
        }
        
        firmwareFiles = sortedFirmwares ?? []

    }
    
    var body: some View{
        VStack (alignment: .center) {
            Text("Meshtastic Flasher")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top)
            Text("Wireless Firmware Update Tool for ESP32 Devices version 2.0.7")
                .font(.title2)
                .multilineTextAlignment(.center)
            Spacer()
            
            HStack{
                
                if !ble.connected {
                    
                    Button(action: {
                        ble.startScanning()
                    }) {
                        Label("Connect", systemImage: "antenna.radiowaves.left.and.right")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding()
                    
                } else {
                    VStack {
                        Text("Connected Meshtastic Device:")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .tint(.green)
                            .padding(.top)
                        Text(ble.name)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .tint(.green)
                            .padding(.bottom)
                        
                        if !ble.transferOngoing {
                            
                            Button(role: .destructive, action: {
                                ble.disconnect()
                            }) {
                                Label("Disconnect", systemImage: "antenna.radiowaves.left.and.right.slash")
                            }
                            .buttonStyle(.bordered)
                            .buttonBorderShape(.capsule)
                            .controlSize(.large)
                        
                            Text("Select a Device")
                                .font(.largeTitle)
                            Picker("Select File", selection: $selectedFile ) {
                                ForEach(firmwareFiles) { file in
                                    Text(file.name)
                                        .tag(file.name)
                                }
                            }
                            .pickerStyle(.wheel)
                            .scaleEffect(1.5)
                            .padding()
                            .clipped()
                        }
                        Spacer()
                    }
                }
            }
           
            if ble.connected && ble.transferOngoing {
                VStack {
                
                    Text("Uploading Firmware. .  .")
                        .font(.title)
                        .bold()
                    Text("Transfer speed : \(ble.kBPerSecond, specifier: "%.1f") kB/s")
                    Text("Elapsed time : \(ble.elapsedTime, specifier: "%.1f") s")
                        .padding(.bottom)
                    ProgressView(value: (ble.transferProgress / 100))
                        .scaleEffect(x: 1, y: 8, anchor: .center)
                        .accentColor(.green)
                        .padding()
                }
            }
            
           
            if ble.connected && !ble.transferOngoing {
                HStack{
                    Button(action: {
                        let selectedFirmware = firmwareFiles.first(where: { $0.name == selectedFile })
                        ble.sendFile(filename: selectedFirmware!.value, fileEnding: ".bin")
                    }) {
                        Label("Update Firmware", systemImage: "arrow.up.doc")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding()

                }
                Spacer()
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .padding()
        
        Spacer()
    }
}
