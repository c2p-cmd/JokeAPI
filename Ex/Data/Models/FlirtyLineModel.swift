//
//  FlirtyLineModel.swift
//  Ex
//
//  Created by Sharan Thakur on 24/07/23.
//

import Foundation

class FlirtyLineModel: Codable, Hashable, RawRepresentable {
    let pickup: String
    
    enum CodingKeys: String, CodingKey {
        case pickup
    }
    
    init(pickup: String) {
        self.pickup = pickup
    }
    
    required init(rawValue: String) {
        self.pickup = rawValue
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.pickup = try container.decode(String.self, forKey: .pickup)
    }
    
    var rawValue: String {
        self.pickup
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.pickup, forKey: .pickup)
    }
}
