//: [Previous](@previous)

import Foundation

/// Tuple<Optional<Array>> ==> Optional<Array<Tuple>> # shift left
/// Tuple<Optional<Array>> ==> Array<Tuple<Optional>> # shift right

// [A]?, [B]? -->optionalZip--> ([A], [B])?

// ([A], [B]) -->optionalArray--> [(A, B)]?

struct F4<Input, Return> {
    let run: (@escaping (Input) -> Return) -> Return
}

func zip2<InputA, InputB, Return>(_ fa: F4<InputA, Return>, _ fb: F4<InputB, Return>) -> F4<(InputA, InputB), Return> {
    return F4 { tupleTaking -> Return in
        var ret: Return
        
        return fa.run { inputA -> Return in
            return fb.run { inputB -> Return in
                return tupleTaking((inputA, inputB))
            }
        }
    }
}

let fa = F4<Int, String> { $0(4) }

let fb = F4<Double, String> { $0(2.1) }

let fc = zip2(fa, fb)

fc.run({ tuple in
    print(tuple)
    return String(describing: tuple)
})

//: [Next](@next)
