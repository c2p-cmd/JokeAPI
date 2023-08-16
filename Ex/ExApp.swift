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
                .onAppear {
//                    let domain = Bundle.main.bundleIdentifier!
//                    appStorage.removePersistentDomain(forName: domain)
//                    appStorage.synchronize()
//                    print(domain)
//                    print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
//                    print(Array(appStorage.dictionaryRepresentation().keys).count)
//                    
//                    for (k, _) in appStorage.dictionaryRepresentation() {
//                        appStorage.removeObject(forKey: k)
//                    }
                    
                    let deviceId = UIDevice.current.identifierForVendor?.uuidString
                    print("My Device ID is: \(deviceId ?? "NO ID!")")
                }
//                .onAppear {
//                    for family in UIFont.familyNames.sorted() {
//                        let names = UIFont.fontNames(forFamilyName: family)
//                        print("Family: \(family) Font names: \(names)")
//                    }
//                }
        }
    }
}
