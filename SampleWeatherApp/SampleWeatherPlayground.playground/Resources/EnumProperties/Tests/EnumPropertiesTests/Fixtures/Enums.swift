

enum Validated<Valid, Invalid> {
    case valid(Valid)
    case invalid([Invalid])
}


enum Optional<A> {
    case some(A)
    case none
}


enum Multiple<A, B, C> {
    case zero
    case one(A)
    case two(B, A)
    case three(C, A, B)
}


enum Node {
    case el(tag: String, attributes: [String: String], children: [Node])
    case text(String)
}


enum Node2 {
    case el(children: [Node])
    case text(String)
}

