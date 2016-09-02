//
//  JSONValueSource.swift
//  SJSON
//
//  Created by Ben Johnson on 30/08/2016.
//
//

import Foundation

public protocol JSONTransformer {
    init()}

public struct JSONDefaultTransformer: JSONTransformer, JSONDefaultValueSource {
    public init() {}
}

public protocol JSONValueSource {
    
    var rawValue: AnyObject? { get }
    
    init(rawValue: AnyObject?)
    
   // associatedtype JSONObjectType: JSONObjectContainer
    
    associatedtype KeySource: JSONKeySource
     
    associatedtype JSONType = JSONValueType
    
    associatedtype Converter: JSONTransformer
    

}

public protocol JSONKeyProvider {
    var key: String? { get }
}
