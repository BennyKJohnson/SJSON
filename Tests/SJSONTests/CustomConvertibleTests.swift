//
//  CustomConvertibleTests.swift
//  SJSON
//
//  Created by Ben Johnson on 1/09/2016.
//
//

import XCTest
@testable import SJSON

class DateFormatterCache {
    static let sharedFormatter = DateFormatterCache()
    static var cache = [String : DateFormatter]()
    private init() {}
    
    func cachedFormatter(format: String) -> DateFormatter {
        if let cachedFormatter = DateFormatterCache.cache[format] {
            return cachedFormatter
        } else {
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = format
            DateFormatterCache.cache[format] = newFormatter
            
            return newFormatter
        }
    }
    
    var RFC3339DateFormatter: DateFormatter {
        return cachedFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ")
    }
}

protocol ValProvider {
    init()
}

struct CustomValueSourceA: ValProvider {}

protocol CustomValueSource {}

public struct CustomValueTransformer: JSONTransformer, CustomValueSource {
    public init() {}
}

typealias SpecialJSONValue<Keys: JSONKeySource> = JSONCustomValue<Keys, CustomValueTransformer>

enum MyKeys: String, JSONKeySource {
    case test
}



typealias MyJSONObject<Keys: JSONKeySource> = JSONCustomObject<SpecialJSONValue<Keys>>

extension JSONValueProvider where Converter: CustomValueSource {
    var date: Date? {
        return nil
    }
}

class CustomConvertibleTests: XCTestCase {

    enum TestKeys: String, JSONKeySource {
        case integer
        case decimal
        case dates
        case string
        case bool
        case dictionary
        case numbers
        case strings
        case animals
        case subjects
        case animal
        case decimals
        case timelineDate
    }
    
    func path() -> String {
        let parent = (#file).components(separatedBy: "/").dropLast().joined(separator: "/")
        return parent
    }
    
    lazy var jsonDictionary: [String: AnyObject]  = {
        
        let jsonURL = URL(fileURLWithPath: self.path() + "/Supporting/test.json")
        print(jsonURL)
        let data = try! Data(contentsOf: jsonURL)
        let dictionary = (try! JSONSerialization.jsonObject(with: data, options: [])) as! [String: AnyObject]
        
        return dictionary
    }()
    
    func testCustomDate() {
        
        let json = MyJSONObject<TestKeys>(dictionary: jsonDictionary)
        let dates:[Date] = json[.timelineDate].array()
        XCTAssertNotNil(dates.first)
        let expectedDate = Date(timeIntervalSince1970: 1472782141.303575)
        XCTAssertEqual(Int(dates.first!.timeIntervalSince1970), Int(expectedDate.timeIntervalSince1970))
    }
}
