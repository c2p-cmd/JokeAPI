//
//  IntentHandler.swift
//  MyIntentHandler
//
//  Created by Sharan Thakur on 11/08/23.
//

import Intents

class IntentHandler: INExtension, TVShowIntentIntentHandling, JokeCategoryChoiceIntentHandling {
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func provideTvShowChoiceOptionsCollection(
        for intent: TVShowIntentIntent,
        searchTerm: String?,
        with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void
    ) {
        let allShows = TVShowQuoteResponses.allShows
        
        if let searchTerm {
            let fileteredArray = allShows.filter { element in
                return element.contains(searchTerm)
            }.asNSSTring()
            
            completion(INObjectCollection<NSString>(items: fileteredArray), nil)
            return
        }
        
        let tvShowsOptions: [NSString] = allShows.asNSSTring()
        
        let collection = INObjectCollection<NSString>(items: tvShowsOptions)
        
        completion(collection, nil)
    }
    
    func provideJokeCategoryOptionsCollection(
        for intent: JokeCategoryChoiceIntent,
        searchTerm: String?,
        with completion: @escaping (INObjectCollection<NSString>?, Error?) -> Void
    ) {
        let arrayOfJokeCategories = [
            "Any",
            "Pun",
            "Spooky",
            "Christmas",
//            "Dark",
            "Misc",
            "Programming"
        ]
        
        if let searchTerm {
            let filteredArray = arrayOfJokeCategories.filter { $0.contains(searchTerm) }.asNSSTring()
            
            completion(INObjectCollection(items: filteredArray), nil)
            return
        }
        
        let nsStringArray = arrayOfJokeCategories.asNSSTring()
        
        completion(INObjectCollection(items: nsStringArray), nil)
    }
}
