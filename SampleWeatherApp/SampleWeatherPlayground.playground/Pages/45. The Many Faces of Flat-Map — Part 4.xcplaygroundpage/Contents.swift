//: [Previous](@previous)

import Foundation

// compactMap: ((A) -> B?) -> (([A]) -> [B])
// compactMap: ((A) -> B?) -> ((F<A>) -> F<B>)

// F<A> = Array<A> => ((A) -> B?) -> (([A]) -> [B])
// F<A> = Optional<A> => ((A) -> B?) -> ((A?) -> B?)
// F<A> = Result<A, E> => ((A) -> B?) -> ((Result<A, E>) -> Result<B, E>)
// F<A> = Validated<A, E> => ((A) -> B?) -> ((Validated<A, E>) -> Validated<B, E>)
// F<A> = Func<A0, A> => ((A) -> B?) -> ((Func<A0, A>) -> Func<A0, B>)
// F<A> = Parallel<A> => ((A) -> B?) -> ((Parallel<A>) -> Parallel<B>)

func fromThrowing<A, B>(_ f: @escaping (A) throws -> B) -> (A) -> Result<B, Swift.Error> {
    return { a in
        do {
            return .success(try f(a))
        } catch let error {
            return .failure(error)
        }
    }
}

func toThrowing<A, B>(_ f: @escaping (A) -> Result<B, Swift.Error>) -> ((A) throws -> B) {
    return { a in
        switch f(a) {
        case let .success(value): return value
        case let .failure(error): throw error
        }
    }
}

fromThrowing(Data.init(from:))

//extension Func /* <A, B> */ {
//    func flatMap<C>(_ f: @escaping (A) -> Func<C, B>) -> Func<C, B> {
//
//    }
//}

import XCTest

struct Diffing<Value> {
    let toData: (Value) -> Data
    let fromData: (Data) -> Value
    let diff: (Value, Value) -> (String, [XCTAttachment])?
    
    func flatMap<NewValue>(_ f: @escaping (Value) -> Diffing<NewValue>) -> Diffing<NewValue> {
        fatalError("not possible to implement")
    }
}

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
    
    func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in callback(f(a)) }
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in
                f(a).run { b in
                    callback(b)
                }
            }
        }
    }
}


extension Parallel {
    func then<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
        return self.flatMap(f)
    }
}

extension Parallel {
    func then<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return self.map(f)
    }
}

extension Parallel {
    init(_ work: @autoclosure @escaping () -> A) {
        self = Parallel { callback in
            DispatchQueue.global(qos: .background).async {
                callback(work())
            }
        }
    }
}

struct User: Codable {
    let email: String
    let id: Int
    let name: String
}

Parallel(Bundle.main.path(forResource: "user", ofType: "json")!)
    .map(URL.init(fileURLWithPath:))
    .flatMap { url in Parallel(try! Data.init(contentsOf: url)) }
    .flatMap { data in Parallel(try! JSONDecoder().decode(User.self, from: data)) }

Parallel(Bundle.main.path(forResource: "user", ofType: "json")!)
    .then(URL.init(fileURLWithPath:))
    .then { url in Parallel(try! Data.init(contentsOf: url)) }
    .then { data in Parallel(try! JSONDecoder().decode(User.self, from: data)) }



//: [Next](@next)
