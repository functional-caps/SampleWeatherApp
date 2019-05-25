//: [Previous](@previous)

import Foundation

func randomString() -> String {
    return Array(repeating: (), count: .random(in: 0...280))
        .map { String(UnicodeScalar(UInt8.random(in: .min ... .max))) }
        .joined()
}

struct ArbitraryDecoder: Decoder {
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
        where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer())
    }
    
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        
        var codingPath: [CodingKey] = []
        var allKeys: [Key] = Array(repeating: (), count: .random(in: 1...10))
            .map { _ in Key(stringValue: randomString()) }
            .compactMap { $0 }

        func contains(_ key: Key) -> Bool {
            return true
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            return .random()
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            return try T(from: ArbitraryDecoder())
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return KeyedDecodingContainer(KeyedContainer<NestedKey>())
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        func superDecoder() throws -> Decoder {
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError()
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return UnkeyedContainer(decoder: self)
    }
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        
        var codingPath: [CodingKey] = []
        
        var count: Int? = .random(in: 0...20)
        
        var isAtEnd: Bool {
            guard let count = count else { return true }
            return currentIndex == (count - 1)
        }
        
        var currentIndex: Int = 0
        
        let decoder: Decoder
        
        init(decoder: Decoder) {
            self.decoder = decoder
        }
        
        mutating func decodeNil() throws -> Bool {
            return .random()
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            currentIndex += 1
            return try T(from: decoder)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            return KeyedDecodingContainer(KeyedContainer())
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            return UnkeyedContainer(decoder: decoder)
        }
        
        mutating func superDecoder() throws -> Decoder {
            currentIndex += 1
            return decoder
        }
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer()
    }
    
    struct SingleValueContainer: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []
        
        func decodeNil() -> Bool {
            return .random()
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            return .random()
        }
        
        func decode(_ type: String.Type) throws -> String {
            return randomString()
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            return .random(in: -1_000_000_000...1_000_000_000)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            return .random(in: 0...1)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return .random(in: .min ... .max)
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T(from: ArbitraryDecoder())
        }
    }
}

try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())
try Bool(from: ArbitraryDecoder())

try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())
try Int(from: ArbitraryDecoder())

try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())
try Float(from: ArbitraryDecoder())

try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())
try String(from: ArbitraryDecoder())

try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())
try Date(from: ArbitraryDecoder())

struct User: Decodable {
    let id: Int
    let name: String
    let email: String
}

try User(from: ArbitraryDecoder())

/*
 
 Exercise 1.
 
 We skipped over the allKeys property of the KeyedDecodingContainerProtocol, but it’s what’s necessary to decode dictionaries of values. On initialization of the KeyedDecodingContainer, generate a random number of random CodingKeys to populate this property.
 
 You’ll need to return true from contains(_ key: Key).
 
 Decode a few random dictionaries of various decodable keys and values. What are some of the limitations of decoding dictionaries?
 
 */

print(try Dictionary<String, Int>(from: ArbitraryDecoder()))
print(try Dictionary<String, User>(from: ArbitraryDecoder()))
//try Dictionary<Int, String>(from: ArbitraryDecoder())

// limitations: you have to decide whether your decoder supports string or int keyes

 /*
 
 Exercise 2.
 
 Create a new UnkeyedContainer struct that conforms to the UnkeyedContainerProtocol and return it from the unkeyedContainer() method of ArbitraryDecoder. As with the KeyedDecodingContainer, you can delete the same decode methods and have them delegate to the SingleValueContainer.
 
 The count property can be used to generate a randomly-sized container, while currentIndex and isAtEnd can be used to let the decoder know how far along it is. Generate a random count, default the currentIndex to 0, and define isAtEnd as a computed property using these values. The currentIndex property should increment whenever superDecoder is called.
 
 Decode a few random arrays of various decodable elements.
 
 */

print(try [Int](from: ArbitraryDecoder()))
print(try [String](from: ArbitraryDecoder()))
print(try [User](from: ArbitraryDecoder()))

//: [Next](@next)
