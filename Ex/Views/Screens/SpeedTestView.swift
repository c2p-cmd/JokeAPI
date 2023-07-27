//
//  SpeedTestView.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import SwiftUI
import WidgetKit

struct SpeedTestView: View {
    private let downloadService = DownloadService.shared
    
    @AppStorage("net_speed") var currentSpeed: Speed = UserDefaults.savedSpeed
    @State var avgSpeed: Speed? = nil
    @State var error: Error? = nil
    @State var isBusy = false
    @State var pingMS: Int? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 33) {
            Text("Hello, world!")
            
            if let pingMS {
                Text("Ping: \(pingMS) ms")
                    .tint(.cyan)
            }
            
            Text("\(isBusy ? "CurrentSpeed" : "Final Speed") \(currentSpeed.description)")
            if let avgSpeed = avgSpeed {
                Text("AvgSpeed \(avgSpeed.description)")
            }
            if let error = error {
                Text(error.localizedDescription)
            }
            
            RefreshButton(isBusy: self.$isBusy, action: self.test)
        }
        .padding([.vertical, .trailing], 18)
    }
    
    private func test() {
        if self.isBusy {
            return
        }
        
        url.ping(timeout: 60) { res in
            switch res {
            case .success(let pingMS):
                self.pingMS = pingMS
                break
            case .failure(let error):
                self.error = error
                break
            }
        }
        
        self.isBusy = true
        downloadService.test(
            for: url,
            timeout: 60,
            current: { current, avg in
                self.avgSpeed = avg
                self.currentSpeed = current
                self.error = nil
            },
            final: { result in
                
                switch result {
                case .success(let speed):
                    self.error = nil
                    self.currentSpeed = speed
                    WidgetCenter.shared.reloadTimelines(ofKind: "SpeedTestWidget")
                    break
                case .failure(let err):
                    self.error = err
                    break
                }
                
                self.isBusy = false
            }
        )
    }
}
