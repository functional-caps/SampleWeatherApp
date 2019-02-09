//
//  Either.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 08/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

enum Either<L, R> {
    case left(L)
    case right(R)
}

func toEither<V, T>(withR: T.Type) -> (V) -> Either<V, T> {
    return { v in
        return .left(v)
    }
}

func toEither<V, T>(withL: T.Type) -> (V) -> Either<T, V> {
    return { v in
        return .right(v)
    }
}
