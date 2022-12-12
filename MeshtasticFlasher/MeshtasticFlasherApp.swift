//
//  MeshtasticFlasher.swift
//  Inspired by https://github.com/ClaesClaes/Arduino-ESP32-NimBLE-OTA-iOS-SwiftUI
//  Created by Garth Vander Houwen on 12/4/22
//

import SwiftUI

@main
struct MeshtasticFlasherApp: App {

    var ble  = BLEConnection()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(ble)
            }.navigationViewStyle(.stack)
        }
    }
}
