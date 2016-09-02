import Foundation

// Define our JSON Key protocol
public protocol JSONKeySource {
    var keyValue : String { get }
}

// Implement keyValue for Enum of Type == String to JSONKeySource
public extension RawRepresentable where RawValue == String {
    var keyValue: String {
        return rawValue
    }
}

public struct JSONCustomObject<Value: JSONValueSource>: JSONObjectSource {
    
    public typealias KeySource = Value.KeySource
    
    // Update ValueType to include JSONKeySource
    public typealias ValueType = Value
    
    public let dictionary: [String : AnyObject]
    
    public init(dictionary: [String: AnyObject]) {
        self.dictionary = dictionary
    }
}

protocol JSONValueProvider: JSONValueSource, JSONNumberProvider, JSONPrimitiveValueProvider, JSONThrowable, JSONEnumProvider, JSONArrayProvider, JSONObjectProvider {}


public protocol JSONDefaultValueSource {}

public struct JSONCustomValue<Keys:JSONKeySource, Transformer: JSONTransformer>: JSONValueProvider {
    
    public let rawValue: AnyObject?
    
    public var key: String?
    
    public typealias KeySource = Keys
    
    public typealias Converter = Transformer

    public init(rawValue: AnyObject?) {
        self.rawValue = rawValue
    }
    
}

// Convenience default unwrappers
public typealias JSONValue<Keys: JSONKeySource> = JSONCustomValue<Keys, JSONDefaultTransformer>

public typealias JSONObject<Keys: JSONKeySource> = JSONCustomObject<JSONValue<Keys>>
