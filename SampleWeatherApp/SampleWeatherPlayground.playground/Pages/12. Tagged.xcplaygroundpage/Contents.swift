//: [Previous](@previous)

enum EmailType {}
typealias Email = Tagged<EmailType, String>

struct User {

    typealias Id = Tagged<User, Int>

    let id: Id
    let name: String
    let email: Email
    let subscriptionId: Int?
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = RawValue.IntegerLiteralType

    public init(integerLiteral value: IntegerLiteralType) {
        self.init(rawValue: RawValue(integerLiteral: value))
    }
}

/*

 Exercise 1:

 Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.

 Answer 1:

 */

extension Tagged: ExpressibleByStringLiteral,
    ExpressibleByExtendedGraphemeClusterLiteral,
    ExpressibleByUnicodeScalarLiteral
where RawValue: ExpressibleByStringLiteral {

    public typealias StringLiteralType = RawValue.StringLiteralType
    public typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: value))
    }

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(rawValue: RawValue(unicodeScalarLiteral: value))
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: value))
    }
}

let email: Email = "krzysztof@siejkowski.net"
print(email)

/*

 Exercise 2:

 Conditionally conform Tagged to Comparable and sort users by their id in descending order.

 Answer 2:

 */

extension Tagged: Comparable, Equatable where RawValue: Comparable {

    public static func <(lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    public static func ==(lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

let users = [
    User(id: 5, name: "5", email: "5", subscriptionId: nil),
    User(id: 7, name: "7", email: "7", subscriptionId: nil),
    User(id: 2, name: "2", email: "2", subscriptionId: nil),
    User(id: 3, name: "3", email: "3", subscriptionId: nil),
    User(id: 9, name: "9", email: "9", subscriptionId: nil),
    User(id: 1, name: "1", email: "1", subscriptionId: nil)
]

users
    .sorted { $0.id < $1.id }

/*

 Exercise 3:

 Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)

 Answer 3:

 */

struct UserWithAge {

    enum IdType {}
    typealias Id = Tagged<IdType, Int>

    enum AgeType {}
    typealias Age = Tagged<AgeType, Int>

    let id: Id
    let name: String
    let email: Email
    let subscriptionId: Int?
    let age: Age
}

/*

 Exercise 4:

 Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.

 Answer 4:

 */

extension Tagged: AdditiveArithmetic where RawValue: Numeric, RawValue: Comparable {

    public typealias Magnitude = RawValue.Magnitude

    public var magnitude: Magnitude { return rawValue.magnitude }

    public init?<T>(exactly source: T) where T : BinaryInteger {
        if let value = RawValue(exactly: source) {
            self.init(rawValue: value)
        } else {
            return nil
        }
    }

    public static func * (lhs: Tagged<Tag, RawValue>,
                          rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
        return Tagged(rawValue: lhs.rawValue * rhs.rawValue)
    }

    public static func *= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
        lhs = Tagged(rawValue: lhs.rawValue * rhs.rawValue)
    }

    public static func + (lhs: Tagged<Tag, RawValue>,
                          rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
        return Tagged(rawValue: lhs.rawValue + rhs.rawValue)
    }

    prefix static func + (x: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
        return Tagged(rawValue: +x.rawValue)
    }

    public static func += (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
        lhs = Tagged(rawValue: lhs.rawValue + rhs.rawValue)
    }

    public static func - (lhs: Tagged<Tag, RawValue>,
                          rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
        return Tagged(rawValue: lhs.rawValue - rhs.rawValue)
    }

    public static func -= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
        lhs = Tagged(rawValue: lhs.rawValue - rhs.rawValue)
    }
}

enum CentsType {}
typealias Cents = Tagged<CentsType, Int>

let cents: Cents = 92
cents - 12
cents * 2

/*

 Exercise 5:

 Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.

 Answer 5:

 */

import UIKit

protocol OnOffType {}
enum OnType: OnOffType {}
enum OffType: OnOffType {}

typealias Light<A> = Tagged<A, UIColor> where A: OnOffType

func retag<A, B, Value>(_ newTag: B.Type) -> (Tagged<A, Value>) -> Tagged<B, Value> {
    return { tag in
        return Tagged<B, Value>(rawValue: tag.rawValue)
    }
}


extension Light where Tag == OffType, RawValue == UIColor {
    func turnOn() -> Light<OnType> {
        return self |> retag(OnType.self)
    }
}

extension Light where Tag == OnType, RawValue == UIColor {
    func turnOff() -> Light<OffType> {
        return Light<OffType>(rawValue: rawValue)
    }
}

let light = Light<OffType>(rawValue: .blue)
let onLight = light.turnOn()
onLight.turnOff()

/*

 Exercise 6:

 Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.

 Answer 6:

 */

extension Light where Tag == OnType, RawValue == UIColor {
    func changeColor(_ color: UIColor) -> Light<OnType> {
        return Light(rawValue: color)
    }
}

let blueLight =
    Light<OnType>(rawValue: .blue)
        .changeColor(.red)

/*

 Exercise 7:

 Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.

 Answer 7:

 */

enum CelciusType {}
enum FahrenheitType {}

typealias Celcius = Tagged<CelciusType, Double>
typealias Fahrenheit = Tagged<FahrenheitType, Double>

extension Tagged where Tag == CelciusType, RawValue == Double {
    func celsiusToFahrenheit() -> Fahrenheit {
        return Fahrenheit(rawValue: rawValue * 1.8 + 32)
    }
}

extension Tagged where Tag == FahrenheitType, RawValue == Double {
    func fahrenheitToCelcius() -> Celcius {
        return Celcius(rawValue: (rawValue - 32) / 1.8)
    }
}

let celcius: Celcius = 32
celcius
    .celsiusToFahrenheit()
    .fahrenheitToCelcius()


/*

 Exercise 8:

 Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.

 Answer 8:

 */

enum ValidatedType {}
typealias Validated<A> = Tagged<ValidatedType, A>

enum UnvalidatedType {}
typealias Unvalidated<A> = Tagged<UnvalidatedType, A>

func validate(unvalidated: Unvalidated<User>) -> Validated<User>? {
    let email = unvalidated.rawValue.email.rawValue
    guard !email.isEmpty && email.contains("@") else { return nil }
    return Validated(rawValue: unvalidated.rawValue)
}

let properUser = User(id: 1, name: "a", email: "a@b.c", subscriptionId: nil)
let unproperUser = User(id: 1, name: "a", email: "a[at]b.c", subscriptionId: nil)

validate(unvalidated: Unvalidated(rawValue: properUser))
validate(unvalidated: Unvalidated(rawValue: unproperUser))

//: [Next](@next)
