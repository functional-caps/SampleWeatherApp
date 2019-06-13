//: [Previous](@previous)

import Foundation

struct Gen<A> {
    let run: () -> A
}

import Darwin
let random = Gen(run: arc4random)

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

//let uniform = random.map { Double($0) / Double(UInt32.max) }

extension Gen
    where A: BinaryFloatingPoint, A.RawSignificand: FixedWidthInteger {

    static func float(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { .random(in: range) }
    }
    
    //    return uniform.map { t in
    //        t * (range.upperBound - range.lowerBound) + range.lowerBound
    //    }
}

import UIKit
Gen<CGFloat>.float(in: 0...1)

//let uint64: Gen<UInt64> = .init {
//    let lower = UInt64(random.run())
//    let upper = UInt64(random.run()) << 32
//    return upper + lower
//}

extension Gen where A: FixedWidthInteger {

    static func int(in range: ClosedRange<A>) -> Gen<A> {
        return Gen { .random(in: range) }
    }
//    return Gen<Int> {
//        var delta = UInt64(truncatingIfNeeded: range.upperBound &- range.lowerBound)
//        if delta == UInt64.max {
//            return Int(truncatingIfNeeded: uint64.run())
//        }
//        delta += 1
//        let tmp = UInt64.max % delta + 1
//        let upperBound = tmp == delta ? 0 : tmp
//        var random: UInt64 = 0
//        repeat {
//            random = uint64.run()
//        } while random < upperBound
//        return Int(truncatingIfNeeded: UInt64(truncatingIfNeeded: range.lowerBound))
//            &+ Int(random % delta)
//    }
}


//let bool = int(in: 0...1).map { $0 == 1 }

extension Gen where A == Bool {
    static let bool = Gen { .random() }
}

extension Gen {
    
    static func element(of xs: [A]) -> Gen<A?> {
        return Gen<A?> { xs.randomElement() }
    }
//    return int(in: 0...(xs.count - 1)).map { idx in
//        guard !xs.isEmpty else { return nil }
//        return xs[idx]
//    }
}

extension Gen {
    func array(of count: Gen<Int>) -> Gen<[A]> {
        return count.map { count in
            var array: [A] = []
            for _ in 1...count {
                array.append(self.run())
            }
            return array
        }
    }
}

func zip<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen<(A, B)> {
        (ga.run(), gb.run())
    }
}

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { zip($0, $1).map(f) }
}

func zip4<A, B, C, D, Z>(with f: @escaping (A, B, C, D) -> Z) -> (Gen<A>, Gen<B>, Gen<C>, Gen<D>) -> Gen<Z> {
    return { a, b, c, d in
        Gen<Z> { f(a.run(), b.run(), c.run(), d.run()) }
    }
}

extension Gen {
    static func always(_ a: A) -> Gen<A> {
        return Gen { a }
    }
}

let color = zip4(with: UIColor.init(red:green:blue:alpha:))(
    .float(in: 0...1),
    .float(in: 0...1),
    .float(in: 0...1),
    .always(1)
)

color.run()

let pixel: Gen<UIImage> = color.map { color -> UIImage in
    let rect = CGRect.init(x: 0, y: 0, width: 1, height: 1)
    return UIGraphicsImageRenderer.init(bounds: rect).image { context in
        context.cgContext.setFillColor(color.cgColor)
        context.cgContext.fill(rect)
    }
}

pixel.run()

let randomRect = zip4(with: CGRect.init(x:y:width:height:))(
    .always(CGFloat.zero),
    .always(CGFloat.zero),
    .float(in: 50...400),
    .float(in: 50...400)
)

randomRect.run()

let pixelImageView = zip(pixel, randomRect).map { pixel, rect -> UIImageView in
    let imageView = UIImageView(image: pixel)
    imageView.bounds = rect
    return imageView
}

pixelImageView.run()
pixelImageView.run()
pixelImageView.run()
pixelImageView.run()

var srng = SystemRandomNumberGenerator()
Int.random(in: 1...10, using: &srng)

struct MockRandomNumberGenerator: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        return 42
    }
}

var mrng = MockRandomNumberGenerator()
Int.random(in: 1...10, using: &mrng)
Int.random(in: 1...10, using: &mrng)
Int.random(in: 1...10, using: &mrng)
Int.random(in: 1...10, using: &mrng)

struct LCRNG: RandomNumberGenerator {
    var seed: UInt64
    
    init(seed: UInt64) {
        self.seed = seed
    }
    
    mutating func next() -> UInt64 {
        seed = 2862933555777941757 &* seed &+ 3037000493
        return seed
    }
}

var lcrng = LCRNG(seed: 42)

Int.random(in: 1...10, using: &lcrng)
Int.random(in: 1...10, using: &lcrng)
Int.random(in: 1...10, using: &lcrng)

lcrng.seed = 42

Int.random(in: 1...10, using: &lcrng)
Int.random(in: 1...10, using: &lcrng)
Int.random(in: 1...10, using: &lcrng)

struct AnyRandomNumberGenerator: RandomNumberGenerator {
    var rng: RandomNumberGenerator
    
    mutating func next() -> UInt64 {
        return rng.next()
    }
}

struct Environment {
    var rng = AnyRandomNumberGenerator(rng: SystemRandomNumberGenerator())
}

var Current = Environment()

Int.random(in: 1...100, using: &Current.rng)
Int.random(in: 1...100, using: &Current.rng)
Int.random(in: 1...100, using: &Current.rng)

Current.rng = AnyRandomNumberGenerator(rng: LCRNG(seed: 0))

Int.random(in: 1...100, using: &Current.rng)
Int.random(in: 1...100, using: &Current.rng)
Int.random(in: 1...100, using: &Current.rng)

//: [Next](@next)
