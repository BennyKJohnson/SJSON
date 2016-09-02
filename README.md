# SJSON
The most personal Swift JSON Mapping library.

## Features
- [x] Easily map value types, arrays and enums from JSON values
- [x] Supports custom types
- [x] Modular, extend or modify behaviour of mapping


## Usage 
### Initalizing
SJSON is strongly typed in order to emphasis safety. Keys are not accessed via a traditional string. Instead we define an enum with the collection of available keys.

```swift
enum MovieInfoKey: String, JSONKeySource {
    case overview
    case title
    case runtime
    case releaseDate = "release_date"
}
```
Initalize a JSON Object for our keys
```swift
let json = JSONObject<MovieInfoKey>(data: dataFromNetwork)
```

### Accessing Values
```swift
//Getting a string from a JSON Object
let overview = json[.overview].string
```
```swift
//Getting a double from a JSON Object
let runtime = json[.runtime].double
```

#### Array mapping
SJSON allows for the automatic mapping of JSON array into value types. SJSON uses the array type of variable to determine how to map each value.
```swift
//Getting an array of strings from a JSON Object
let names: [String]? = json[.names].array()
```
```swift
//Getting an array of doubles from a JSON Object
let coordinates: [Double]? = json[.coordinates].array()
```
```swift
//Getting an array of UInt8 from a JSON Object
let colors8Bit: [UInt8]? = json[.colors].array()
```
If you would just prefer an empty array over an optional array
```swift
// Array of values, or if non, emptry array 
let names: [String] = json[.names].array()
```
#### Enum Mapping
SJSON also supports automatic enum mapping
```swift
enum ReleaseStatus: String {
    case pending
    case released
}
// Maps the JSON String Value to the corresponding enum case
let status: ReleaseStatus? = json[.status].enum()
```
Automatically map an array of values to an array of enums
```swift
let statuses: [ReleaseStatus] = json[.statuses].array()
```
#### Throw access
SJSON also has support for throwable access of values for `JSONObject`.
```swift
struct Movie {
    
    let overview: String
    let runtime: Double
    
    init?(json: JSONObject<MovieInfoKey>) {
        do {
            
            overview = try json[.overview].getString()
            runtime = try json[.runtime].getNumber()
            
        } catch {
            if let jsonError = error as? JSONError {
                print(jsonError)
            }
            return nil
        }
    }
}
```
### Custom Value
In order to add support to your own types, you need to implement `JSONValueType` as an extension. This will give you array support and even enum support (If using it as a RawValue) for free.
```swift
// Add support for Date, by translating JSON number as epoch date
extension Date: JSONValueType {
    public static func map(value: Any, for object: Any) -> Date? {
         if let number = value as? NSNumber else {
               return Date(timeIntervalSince1970: number.doubleValue)
         }
        return nil
    }
  }
```
### Customizing how a value is mapped per document
SJSON supports customizations for document specific behaviour, which is useful if you need to map json docs from different sources. For example you need to map two different date formats, in this case the global extension above on date, won't work.

- JSONObject
- JSONValue
- JSONTransformer

We first need to define a struct that implements JSONTransformer, and also define and implement a empty protocol to act as an identifier
```swift
// Our empty identifier protocol for our JSONTransformer
protocol CustomValueSource {}

// Our CustomJSONTransformer
public struct CustomValueTransformer: JSONTransformer, CustomValueSource {
    public init() {}
}
```

Now we define a typealias for a custom json value unwrapper. It's generic so the key source can be passed in. Typealias JSONCustomValue with our keys generic type and 2nd parameter set to a `JSONTransform`, in this case  `CustomValueTransform`
```swift
typealias MyJSONValue<Keys: JSONKeySource> = JSONCustomValue<Keys, CustomValueTransformer>
```
Next we define another typealias which will act as the JSONObjectProvider, we'll use this type when interacting with the json document
```swift
typealias MyJSONObject<Keys: JSONKeySource> = JSONCustomObject<MyJSONValue<Keys>>
```
Finally implement `JSONValueType` on Date
```swift
extension Date: JSONValueType {
    public static func map(value: Any, for object: Any) -> Date? {
       
        switch object {
        case is JSONDefaultValueSource:
            guard let number = value as? NSNumber else {
                return nil
            }
            return Date(timeIntervalSince1970: number.doubleValue)
        case is CustomValueSource:
            if let dateString = value as? String {
                return DateFormatterCache.sharedFormatter.RFC3339DateFormatter.date(from: dateString)
            }
            return nil
            
        default:
            return nil
        }
    }
}
```



