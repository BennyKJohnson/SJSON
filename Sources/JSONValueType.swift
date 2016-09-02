//
//  JSONValueType.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONCustomConvertible {
    
    static func map(value: Any, for object: Any) -> Self?
    
    static func transform(array: [Self]) -> [Self]?
    
    
}

extension JSONCustomConvertible {
    public static func transform(array: [Self]) -> [Self]? {
        return array
    }
}

public protocol JSONValueType: JSONCustomConvertible {}

extension String: JSONValueType {
    public typealias PrimitiveType = NSString
    
    public static func map(value: Any, for object: Any) -> String? {
        return value as? String
    }
}

extension JSONObjectSource {
    public typealias PrimitiveType = [String: AnyObject]
    
}
