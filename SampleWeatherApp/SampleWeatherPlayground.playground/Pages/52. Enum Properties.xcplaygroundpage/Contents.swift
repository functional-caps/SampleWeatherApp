//: [Previous](@previous)

import Foundation

struct User {
    var name: String
    var isAdmin: Bool
}

let user = User(name: "Blob", isAdmin: true)
user.name
user.isAdmin

enum Validated<Valid, Invalid> {
    case valid(Valid)
    case invalid([Invalid])
    
    var valid: Valid? {
        get {
            guard case let .valid(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue = newValue, case .valid = self else { return }
            self = .valid(newValue)
        }
    }
    
    var invalid: [Invalid]? {
        get {
            guard case let .invalid(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue = newValue, case .invalid = self else { return }
            self = .invalid(newValue)
        }
    }
}

let validValue = Validated<Int, String>.valid(42)
let optionalValue: Int?
if case let .valid(value) = validValue {
    optionalValue = value
} else {
    optionalValue = nil
}

optionalValue

let users = [
    User(name: "Blob", isAdmin: true),
    User(name: "Blob, Sr.", isAdmin: true),
    User(name: "Blob, Jr.", isAdmin: false)
]

users
    .filter { $0.isAdmin }
    .map { $0.name }

let validatedValues: [Validated<Int, String>] = [
    .valid(1),
    .invalid(["Failed"]),
    .valid(42)
]


let validatedUsers: [Validated<User, String>] = [
    .valid(User(name: "Blob", isAdmin: true)),
    .invalid(["Failed for Blob Jr."]),
    .valid(User(name: "Blob Sr.", isAdmin: false))
]


validatedValues
    .filter {
        guard case .valid = $0 else { return false }
        return true
    }

validatedValues
    .map { validated  -> Int? in
        guard case let .valid(value) = validated else { return nil }
        return value
    }

validatedValues
    .compactMap { validated  -> Int? in
        guard case let .valid(value) = validated else { return nil }
        return value
    }

prefix operator ^
prefix func ^ <Root, Value>(_ keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in root[keyPath: keyPath] }
}

users
    .filter(^\.isAdmin)
    .map(^\.name)

//users
//    .filter(\.isAdmin)
//    .map(\.name)

let results: [Swift.Result<Int, Error>] = [
    .success(1),
    .failure(NSError(domain: "co.pointfree", code: -1, userInfo: nil)),
    .success(42)
]

results
    .compactMap { try? $0.get() }

results
    .compactMap { result -> Error? in
        guard case let .failure(error) = result else { return nil }
        return error
    }

validatedValues
    .compactMap { $0.valid }

validatedValues
    .compactMap(^\.valid)

validatedValues
    .compactMap(^\.invalid)

validatedUsers
    .compactMap(^\.valid?.name)

//validatedValues
//    .compactMap(\.valid)

/*
 
 Exercise 1.
 
 While we’ve defined the gets of our enum properties, we haven’t defined our sets. Redefine Validated’s valid and invalid properties to have a setter in addition to its getter.
 
 */

// added to Validated definition

/*
 
 Exercise 2.
 
 Take the valid setter for a spin. Assign Validated<Int, String>.valid(1) to a variable and increment the number using the setter.
 
 */

var validNumber = Validated<Int, String>.valid(1)
validNumber.valid? += 1
validNumber

//: [Next](@next)
