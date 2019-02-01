//
//  FunctionalBase.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 04/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
    return f(a)
}

public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
    f(&a)
}

func |> <A>(_ a: A, _ f: (inout A) -> Void) -> A {
    var a = a
    f(&a)
    return a
}

precedencegroup BackwardApplication {
    associativity: right
}

infix operator <|: BackwardApplication

public func <| <A, B>(f: (A) -> B, a: A) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition

public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

precedencegroup BackwardsComposition {
    associativity: right
    higherThan: BackwardApplication
}

infix operator <<<: BackwardsComposition

public func <<< <A, B, C>(g: @escaping (B) -> C, f: @escaping (A) -> B) -> (A) -> C {
    return { x in
        g(f(x))
    }
}

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

public func <> <A>(
    f: @escaping (A) -> A,
    g: @escaping (A) -> A
    ) -> (A) -> A {
    return f >>> g
}

public func <> <A>(
    f: @escaping (inout A) -> Void,
    g: @escaping (inout A) -> Void
    ) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}

public func <> <A: AnyObject>(
    f: @escaping (A) -> Void,
    g: @escaping (A) -> Void
    ) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}
