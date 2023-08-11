//
//  IntentHandler.swift
//  MyIntentHandler
//
//  Created by Sharan Thakur on 11/08/23.
//

import Intents

class IntentHandler: INExtension, TVShowIntentIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func provideTvShowChoiceOptionsCollection(
        for intent: TVShowIntentIntent,
        with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void
    ) {
        let allShows = TVShowQuoteResponses.allShows
        let tvShowsOptions: [NSString] = allShows.map { NSString(string: $0) }
        
        let collection = INObjectCollection<NSString>(items: tvShowsOptions)
        
        completion(collection, nil)
    }
}