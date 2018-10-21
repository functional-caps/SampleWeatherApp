//: [Previous](@previous)

import UIKit

func constraint(
    keyPath: KeyPath<UIView, NSLayoutYAxisAnchor>
) -> (KeyPath<UIView, NSLayoutYAxisAnchor>) -> (UIView) -> (UIView) -> Void {
    return { secondKeyPath in
        return { firstView in
            return { secondView in
                firstView[keyPath: keyPath].constraint(equalTo: secondView[keyPath: secondKeyPath]).isActive = true
            }
        }
    }
}

func constraint(keyPath: KeyPath<UIView, NSLayoutXAxisAnchor>) -> (UIView) -> (UIView) -> Void {
    return { firstView in
        return { secondView in
            firstView[keyPath: keyPath].constraint(equalTo: secondView[keyPath: keyPath]).isActive = true
        }
    }
}

func constraint(keyPath: KeyPath<UIView, NSLayoutDimension>) -> (UIView) -> (UIView) -> Void {
    return { firstView in
        return { secondView in
            firstView[keyPath: keyPath].constraint(equalTo: secondView[keyPath: keyPath]).isActive = true
        }
    }
}

func <> <A, B>(
    f: @escaping (A) -> (B) -> Void,
    g: @escaping (A) -> (B) -> Void
    ) -> (A) -> (B) -> Void {
    return { a in
        return { b in
            f(a)(b)
            g(a)(b)
        }
    }
}

func concat <A, B>(
    _ f: ((A) -> (B) -> Void)...
) -> (A) -> (B) -> Void {
    return { a in
        return { b in
            f.forEach { $0(a)(b) }
        }
    }
}


let firstView = UIView()
let secondView = UIView()

let constraints = concat(
    constraint(keyPath: \.topAnchor)(\.bottomAnchor),
    constraint(keyPath: \.bottomAnchor)(\.bottomAnchor),
    constraint(keyPath: \.leadingAnchor),
    constraint(keyPath: \.trailingAnchor)
)

secondView.addSubview(firstView)

(firstView |> constraints) <| secondView

firstView.constraints
secondView.constraints

/*
 
 
 */

//: [Next](@next)
