//
//  Parallel.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 08/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

typealias Completion<A> = Parallel<A, Void>

struct Parallel<A, B> {
    let run: (@escaping (A) -> Void) -> B
}

extension Parallel {
    func map<C>(_ f: @escaping (A) -> C) -> Parallel<C, B> {
        return self |> (SampleWeatherApp.map <| f)
    }
}

func map<A, B, C>(_ f: @escaping (A) -> B) -> (Parallel<A, C>) -> Parallel<B, C> {
    return { (parallelA: Parallel<A, C>) in
        return Parallel<B, C> { completionB in
            let completionA: (A) -> Void = { a in
                completionB(f(a))
            }
            return parallelA.run(completionA)
        }
    }
}

extension Parallel {

    func flatMap<C>(_ f: @escaping (A) -> Parallel<C, B>) -> Parallel<C, B> {
        return self |> (SampleWeatherApp.flatMap <| f)
    }
    
}

func flatMap<A, B, C>(_ f: @escaping (A) -> Parallel<B, C>) -> (Parallel<A, C>) -> Parallel<B, C> {
    return { (parallelA: Parallel<A, C>) in
        var parallelToReturn: Parallel<B, C>? = nil
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        _ = parallelA.run { a in
            parallelToReturn = f(a)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return parallelToReturn!
    }
}

func sequence<A, B>(_ elems: [Parallel<A, B>]) -> Parallel<[A], [B]> {
    return Parallel<[A], [B]> { completion in
        let dispatchGroup = DispatchGroup()
        var arguments: [A] = []
        var results: [B] = []
        elems.forEach { (parallel: Parallel<A, B>) in
            dispatchGroup.enter()
            let b = parallel.run { a in
                arguments.append(a)
                dispatchGroup.leave()
            }
            results.append(b)
        }
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            completion(arguments)
        }
        return results
    }
}
