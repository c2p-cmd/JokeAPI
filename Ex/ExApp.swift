//
//  ExApp.swift
//  Ex
//
//  Created by Sharan Thakur on 22/05/23.
//

import SwiftUI

@main
struct ExApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .defaultAppStorage(appStorage)
                .preferredColorScheme(.light)
                .task {
                    let _ = UIFont.familyNames
                      .flatMap { UIFont.fontNames(forFamilyName: $0) }
                    async let uiDevice = UIDevice.current
                    
                    let deviceId = await uiDevice.identifierForVendor?.uuidString
                    print("My Device ID is: \(deviceId ?? "NO ID!")")
                    
                    let name = await uiDevice.name
                    let modelName = await uiDevice.localizedModel
                    let systemVersion = await uiDevice.systemVersion
                    
                    print("Details \(name) \(modelName) \(systemVersion)")
                }
        }
    }
}
