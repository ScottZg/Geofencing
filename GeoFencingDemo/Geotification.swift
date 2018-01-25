//
//  Geotification.swift
//  GeoFencingDemo
//
//  Created by zhanggui on 2018/1/23.
//  Copyright © 2018年 zhanggui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


struct GeoKey {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let identifier = "identifier"
    static let note = "note"
    static let eventType  = "eventType"
}


enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}
class Geotification: NSObject, NSCoding, MKAnnotation  {
    var coordinate: CLLocationCoordinate2D
    
    var radius: CLLocationDistance
    
    var identifier: String
    
    var note: String
    var eventType: EventType
    
    
    var title: String? {
        if note.isEmpty {
            return "No Note"
        }
        return note
    }
    
    var subtitle: String? {
        let eventTypeString = eventType.rawValue
        return "\(radius)米周围 - \(eventTypeString)"
    }
    
    init(coordinate: CLLocationCoordinate2D,radius: CLLocationDistance,identifier: String,note: String,eventType: EventType) {
        self.coordinate = coordinate
        self.radius = radius
        self.identifier = identifier
        self.note = note
        self.eventType = eventType
    }
    required init(coder decoder: NSCoder) {
        let latitude = decoder.decodeDouble(forKey: GeoKey.latitude)
        let longitude = decoder.decodeDouble(forKey: GeoKey.longitude)
        coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        radius = decoder.decodeDouble(forKey: GeoKey.radius)
        identifier = decoder.decodeObject(forKey: GeoKey.identifier) as! String
        note = decoder.decodeObject(forKey: GeoKey.note) as! String
        
        eventType = EventType.init(rawValue: decoder.decodeObject(forKey: GeoKey.eventType) as! String)!
        
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(coordinate.latitude, forKey: GeoKey.latitude)
        coder.encode(coordinate.longitude, forKey: GeoKey.longitude)
        coder.encode(radius, forKey: GeoKey.radius)
        coder.encode(identifier, forKey: GeoKey.identifier)
        coder.encode(note, forKey: GeoKey.note)
        coder.encode(eventType.rawValue, forKey: GeoKey.eventType)
    }
}
