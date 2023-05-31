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
    @State private var firmwareReleaseData: FirmwareRelease = FirmwareRelease()
    @State var firmwareFiles: [FirmwareFile]
    @State var selectedFile: String = "tbeam"
    @State var selectedStableFirmwareVersion: String = ""
    @State var selectedFirmwareVersion: String = "0.0.0"
    @State var firmwareGroup: String = "stable"
    
    init () {
        var firmwares: [FirmwareFile]? = []
        let fileURLS = Bundle.main.urls(forResourcesWithExtension: ".bin", subdirectory: "")
        for val in fileURLS ?? [] {
            
            let name = val.relativeString
                .replacingOccurrences(of: "firmware-", with: "")
                .replacingOccurrences(of: "2.1.10.7ef12c7-update.bin", with: "")
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
            Text("Wireless Firmware Update Tool for ESP32 Devices")
                .font(.title2)
                .multilineTextAlignment(.center)
           // Spacer()
            Picker("Yolo level", selection: $firmwareGroup ) {
                Text("Stable").tag("stable")
                Text("Alpha").tag("alpha")
                Text("Pull Request").tag("pullRequests")
            }
            .pickerStyle(.segmented)
            if firmwareGroup == "stable" {
                Picker("Firmware Version", selection: $selectedStableFirmwareVersion ) {
                    ForEach(firmwareReleaseData.releases?.stable ?? [], id: \.id) { fr in
                        Text(fr.title ?? "Unknown")
                            .tag(fr.id)
                            .font(.caption)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            } else if firmwareGroup == "alpha" {
                Picker("Firmware Version", selection: $selectedFirmwareVersion ) {
                    ForEach(firmwareReleaseData.releases?.alpha ?? [], id: \.id) { fr in
                        Link(destination: URL(string: fr.zipUrl ?? "")!) {
                            HStack {
                                Text(fr.title ?? "Unknown")
                                    .tag(fr.id)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            } else if firmwareGroup == "pullRequests" {
                Picker("Firmware Version", selection: $selectedFirmwareVersion ) {
                    ForEach(firmwareReleaseData.pullRequests ?? [], id: \.id) { fr in
                        Link(destination: URL(string: fr.zipUrl ?? "")!) {
                            HStack {
                                Text(fr.title ?? "Unknown")
                                    .tag(fr.id)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
            
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
        .onAppear {
            loadData()
            UIApplication.shared.isIdleTimerDisabled = true
            
            let url = URL(string: "https://github.com/meshtastic/firmware/releases/download/v2.1.10.7ef12c7/firmware-2.1.10.7ef12c7.zip")
            
            let downloadTask = URLSession.shared.downloadTask(with: url!) {
                urlOrNil, responseOrNil, errorOrNil in
                // check for and handle errors:
                // * errorOrNil should be nil
                // * responseOrNil should be an HTTPURLResponse with statusCode in 200..<299

                guard let fileURL = urlOrNil else { return }
                do {
                    let documentsURL = try
                        FileManager.default.url(for: .documentDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: false)
                    let savedURL = documentsURL.appendingPathComponent(fileURL.lastPathComponent)
                    print(fileURL)
                    try FileManager.default.moveItem(at: fileURL, to: savedURL)
                } catch {
                    print ("file error: \(error)")
                }
            }
            downloadTask.resume()
            
        }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
        .padding()
        
        Spacer()
    }
    
    func loadData() {
        
        guard let url = URL(string: "https://api.meshtastic.org/github/firmware/list") else {
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                if let response_obj = try? JSONDecoder().decode(FirmwareRelease.self, from: data) {
                    
                    DispatchQueue.main.async {
                        self.firmwareReleaseData = response_obj
                    }
                }
            }
            
        }.resume()
    }
}


func saveFile(url: URL, destination: URL, completion: @escaping (Bool) -> Void){
    URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) in
        // after downloading your data you need to save it to your destination url
        guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let location = location, error == nil
            else { print("error with the url response"); completion(false); return}
        do {
            try FileManager.default.moveItem(at: location, to: destination)
            print("new file saved")
            completion(true)
        } catch {
            print("file could not be saved: \(error)")
            completion(false)
        }
    }).resume()
}
