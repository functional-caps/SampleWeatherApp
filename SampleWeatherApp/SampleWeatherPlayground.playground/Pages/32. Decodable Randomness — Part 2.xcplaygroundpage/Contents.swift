//: [Previous](@previous)

import Foundation

var str = "Hello, playground"

let random = Gen(run: arc4random)

func uint8(in range: ClosedRange<UInt8>) -> Gen<UInt8> {
    return int(in: Int(UInt8.min) ... Int(UInt8.max))
        .map { UInt8($0) }
}

let string = uint8(in: .min ... .max)
    .map(UnicodeScalar.init >>> String.init)
    .array(count: int(in: 0...280))
    .map { $0.joined() }

string.run()

struct User {
    
    typealias Id = Tagged<User, UUID>
    
    let id: Id
    let name: String
    let email: String
}

let alpha = element(of: Array("abcdefghijklmnopqrstuvwxyz")).map { $0! }

extension Gen where A == Character {
    func string(count: Gen<Int>) -> Gen<String> {
        return self.map(String.init).array(count: count).map { $0.joined() }
    }
}

alpha.run()

let namePart = alpha.string(count: int(in: 4...8))
let capitalNamePart = namePart.map { $0.capitalized }

let randomName = Gen<String> { capitalNamePart.run() + " " + capitalNamePart.run() }

randomName.run()

let randomEmail = namePart.map { $0 + "@pointfree.co" }

let randomId = int(in: 1 ... 100_000_000_000)

let hex = element(of: Array("0123456789ABCDEF")).map { $0! }

func hex(count: Gen<Int>) -> String {
    return hex.string(count: count).run()
}

let uuidString = Gen {
    hex(count: .init { 8 }) + "-" + hex(count: .init { 4 }) + "-" + hex(count: .init { 4 }) + "-" + hex(count: .init { 4 }) + "-" + hex(count: .init { 12 })
    }

let randomUUID = uuidString.map { UUID.init(uuidString: $0) }.map { $0! }.map(User.Id.init)

//let randomUser = Gen {
//    User(id: randomId.run(), name: randomName.run(), email: randomEmail.run())
//}

//print(randomUser.run())
//print(randomUser.run())
//print(randomUser.run())

func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> { return (ga.run(), gb.run()) }
}

zip2(randomId, randomName).run()

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { ga, gb in
        return zip2(ga, gb).map(f)
    }
}

func zip3<A, B, C>(_ ga: Gen<A>, _ gb: Gen<B>, _ gc: Gen<C>) -> Gen<(A, B, C)> {
    return zip2(ga, zip2(gb, gc)).map { ($0, $1.0, $1.1) }
}

func zip3<A, B, C, D>(with f: @escaping (A, B, C) -> D)
    -> (Gen<A>, Gen<B>, Gen<C>) -> Gen<D> {
        return { ga, gb, gc in
            return zip3(ga, gb, gc).map(f)
        }
}

let randomUser2 = zip3(with: User.init)(randomUUID, randomName, randomEmail)

print(randomUser2.run())

/*
 
 Exercise 1.
 
 Redefine Gen‘s base unit of randomness, random, which is a Gen<UInt32> to work with Swift 4.2’s base unit of randomness, the RandomNumberGenerator protocol. The base random type should should change to UInt64.
 
 */

func random(using rng: RandomNumberGenerator) -> Gen<UInt64> {
    var copyRNG = rng
    return Gen { copyRNG.next() }
}

let random2 = random(using: SystemRandomNumberGenerator())
random2.run()
random2.run()
random2.run()

/*
 
 Exercise 2.
 
 Swift 4.2’s protocol-oriented solution allows us to define custom types that conform to RandomNumberGenerator. Update Gen to evaluate given any RandomNumberGenerator by changing run’s signature.
 
 */

struct Gen2<T>
where T : FixedWidthInteger, T : UnsignedInteger {
    let run: (RandomNumberGenerator) -> () -> T
}

let random3 = Gen2<UInt64> { rng in
    var copyRNG = rng
    return { copyRNG.next() }
}

let randomSysRNG = random3.run(SystemRandomNumberGenerator())

randomSysRNG()

/*
 
 Exercise 3.
 
 Use a custom random number generator that can be configured with a stable seed to allow for the Gen type to predictably generate the same random value for a given seed.
 
 You can look to Nate Cook’s playground, shared on the Swift forums, or (for bonus points), you can define your own linear congruential generator (or LCG).
 
 */

/*
 
 Exercise 4.
 
 Write a helper that runs a property test for XCTest! A property test, given a generator and a block of code, will evaluate the block of code with a configurable number of random runs. If the block returns true, the property test passes. It it returns false, it fails. The signature should be the following.
 
 func forAll<A>(_ a: Gen<A>, propertyShouldHold: (A) -> Bool)
 It should, internally, call an XCTAssert function. Upon failure, print out the seed so that it can be reproduced.
 
 */

/*
 
 Exercise 5.
 
 Enhance the forAll API to take file: StaticString = #file, line: UInt = #line, which can be passed to XCTest in order to highlight the correct line on failure.
 
 */

 
 
 

//: [Next](@next)
