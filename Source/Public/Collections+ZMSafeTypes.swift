//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//


import Foundation

private let zmLog = ZMSLog(tag: "SafeTypes")


func lastCallstackFrames() -> String {
    let symbols = Thread.callStackSymbols
    return symbols[0..<(min(7, symbols.count))].joined(separator: "\n")
}


func ObjectWhichIsKindOfClass<T>(dictionary: NSDictionary, key: String, required: Bool, transform: ((String) -> T?)?) -> T? {
    if let object = dictionary[key] as? T {
        return object
    }
    if let transform = transform {
        if let string = dictionary[key] as? String, let object = transform(string) {
            return object
        }
    }
    if dictionary[key] != nil {
        zmLog.error("\(dictionary[key]) is not a valid \(T.self) in \(dictionary). Callstack:\n \(lastCallstackFrames())")
    } else if (required) {
        zmLog.error("nil values for \(key) in \(dictionary). Callstack:\n \(lastCallstackFrames())")
    }
    return nil
}

func RequiredObjectWhichIsKindOfClass<T>(dictionary: NSDictionary, key: String, transform: ((String) -> T?)? = nil) -> T? {
    return ObjectWhichIsKindOfClass(dictionary: dictionary, key: key, required: true, transform: transform)
}

func OptionalObjectWhichIsKindOfClass<T>(dictionary: NSDictionary, key: String, transform: ((String) -> T?)? = nil) -> T? {
    return ObjectWhichIsKindOfClass(dictionary: dictionary, key: key, required: false, transform: transform)
}

public extension NSDictionary {

    public func string(forKey key: String) -> String? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func optionalString(forKey key: String) -> String? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func number(forKey key: String) -> NSNumber? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func optionalNumber(forKey key: String) -> NSNumber? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    public func array(forKey key: String) -> [AnyObject]? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func optionalArray(forKey key: String) -> [AnyObject]? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    public func data(forKey key: String) -> Data? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func optionalData(forKey key: String) -> Data? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func dictionary(forKey key: String) -> [String: AnyObject]? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func optionalDictionary(forKey key: String) -> [String: AnyObject]? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key)
    }
    
    public func uuid(forKey key: String) -> UUID? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key){UUID(uuidString:$0)}
    }
    
    public func optionalUuid(forKey key: String) -> UUID? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key){UUID(uuidString:$0)}
    }
    
    public func date(forKey key: String) -> Date? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key){NSDate(transport: $0) as? Date}
    }
    
    public func optionalDate(forKey key: String) -> Date? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key){NSDate(transport: $0) as? Date}
    }
    
    public func event(forKey key: String) -> ZMEventID? {
        return RequiredObjectWhichIsKindOfClass(dictionary: self, key: key){ZMEventID(string:$0)}
    }
    
    public func optionalEvent(forKey key: String) -> ZMEventID? {
        return OptionalObjectWhichIsKindOfClass(dictionary: self, key: key){ZMEventID(string:$0)}
    }
}


