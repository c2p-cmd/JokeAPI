//
//  JokeWidgetBundle.swift
//  JokeWidget
//
//  Created by Sharan Thakur on 04/06/23.
//

import WidgetKit
import SwiftUI

@main
struct JokeWidgetBundle: WidgetBundle {
    var body: some Widget {
        JokeWidget()
        
        QuoteWidget()
        
        AnimalPictureWidget()
        
        SpeedTestWidget()
    }
}
