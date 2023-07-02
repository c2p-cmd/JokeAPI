//
//  SpeedTestView.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import SwiftUI

struct SpeedTestView: View {
    let downloadService = DownloadService.shared
    @AppStorage("net_speed") var currentSpeed: Speed = UserDefaults.savedSpeed
    @State var avgSpeed: Speed? = nil
    @State var error: Error? = nil
    @State var isBusy = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 33) {
            Text("Hello, world!")
            Text("\(isBusy ? "CurrentSpeed" : "Final Speed") \(currentSpeed.description)")
            if let avgSpeed = avgSpeed {
                Text("AvgSpeed \(avgSpeed.description)")
            }
            if let error = error {
                Text(error.localizedDescription)
            }
            Button("Test") {
                if self.isBusy {
                    return
                }
                
                self.isBusy = true
                error = nil
                downloadService.test(
                    for: url,
                    timeout: 60,
                    current: { current, avg in
                        print("Current: \(current), Avg: \(avg)")
                        self.avgSpeed = avg
                        self.currentSpeed = current
                    },
                    final: { result in
                        switch result {
                        case .success(let speed):
                            print("Speed of \(speed)")
                            self.currentSpeed = speed
                            break
                        case .failure(let err):
                            print(err.localizedDescription)
                            break
                        }
                        
                        self.isBusy = false
                    }
                )
            }.disabled(self.isBusy)
        }
        .padding([.vertical, .trailing], 18)
    }
}
