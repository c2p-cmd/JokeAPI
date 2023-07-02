//
//  SpeedModel.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

// Speed Units
enum Units: Int, Codable {
    case Kbps, Mbps, Gbps
    
    var description: String {
        switch self {
        case .Kbps: return "Kbps"
        case .Mbps: return "Mbps"
        case .Gbps: return "Gbps"
        }
    }
    
    static let allCases: [Units] = [.Kbps, .Mbps, .Gbps]
}

// Coding Keys for storing
enum CodingKeys: String, CodingKey {
    case value
    case unit
}

struct Speed: Codable {
    // frozen variables
    private static let bitsInBytes: Double = 8
    private static let upUnit: Double = 1000
    
    // public variables
    public let value: Double
    public let units: Units
    
    init(value: Double, units: Units) {
        self.value = value
        self.units = units
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.value = try values.decode(Double.self, forKey: .value)
        self.units = try values.decode(Units.self, forKey: .unit)
    }
    
    var pretty: Speed {
        let filtered = Units.allCases.filter { $0.rawValue >= self.units.rawValue }
        let reduced = filtered.reduce(self) { (result, nextUnits) in
            guard result.value > Speed.upUnit else {
                return result
            }
            return Speed(value: result.value / Speed.upUnit, units: nextUnits)
        }
        
        return reduced
    }
    
    public var description: String {
        return String(format: "%.3f", value) + " " + units.description
    }
}

extension Speed {
    // Another Constructor
    static func speedFrom(bytes: Int64, seconds: TimeInterval) -> Speed {
        let speedInB = Double(bytes) * Speed.bitsInBytes / seconds
        return Speed(value: speedInB, units: .Kbps).pretty
    }
    
    func widgetDescription() -> String {
        String(format: "%.1f", value) + " " + units.description
    }
}

// MARK: - AppStorage wrapper
extension Speed: RawRepresentable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }
    
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Speed.self, from: data)
        else {
            return nil
        }
        self = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: .value)
        try container.encode(self.units, forKey: .unit)
    }
}
