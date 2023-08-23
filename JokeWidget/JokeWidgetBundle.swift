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
        
        BhagvatGitaWidget()
        
        QuoteWidget()
        
        SpeedTestWidget()
        
        FlirtyLinesWidget()
        
        TVShowQuoteWidget()
        
        MoreWidgets().body
    }
}

struct MoreWidgets: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        NextMCUFilmWidget()
        
        FunFactAboutTodayWidget()
        
//        CuteAnimalWidget()
        
//        MemeWidget()
        
        AnimalPictureWidget()
        
//        CustomPictureWidget()
        
        NASAApodWidget()
    }
}
