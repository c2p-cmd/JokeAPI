//
//  NumberAPIURLS.swift
//  Ex
//
//  Created by Sharan Thakur on 25/07/23.
//

import Foundation

struct NumberAPI {
    private init() { }
    
    private static let baseUrlString: String = configPlist.value(forKey: "Numbers API LINK") as! String
    
    static func date(month: Int, day: Int) -> String {
        "\(baseUrlString)/\(month)/\(day)/date/"
    }
    
    static func date(formattedDate: String) -> String {
        "\(baseUrlString)/\(formattedDate)/date/"
    }
    
    static func year(_ year: Int) -> String {
        "\(baseUrlString)/\(year)/year/"
    }
    
    static func trivia(num: Int) -> String {
        "\(baseUrlString)/\(num)/trivia/"
    }
    
    static func math(num: Int) -> String {
        "\(baseUrlString)/\(num)/math/"
    }
    
    static func random(num: Int) -> String {
        [math(num: num), trivia(num: num)].randomElement()!
    }
}
