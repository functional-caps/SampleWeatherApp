//
//  Result.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 04/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

enum Result<ValueType, ErrorType> {
    case success(ValueType)
    case failure(ErrorType)
    
    func map<V>(_ f: @escaping (ValueType) -> V) -> Result<V, ErrorType> {
        return self |> SampleWeatherFramework.map(f)
    }
    
    func flatMap<V>(_ f: @escaping (ValueType) -> Result<V, ErrorType>) -> Result<V, ErrorType> {
        return self |> SampleWeatherFramework.flatMap(f)
    }
    
    func mapError<E>(_ f: (ErrorType) -> E) -> Result<ValueType, E> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return .failure(f(error))
        }
    }
    
    func flatMapError<E>(_ f: (ErrorType) -> Result<ValueType, E>) -> Result<ValueType, E> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return f(error)
        }
    }
    
    func recover(_ f: (ErrorType) -> ValueType) -> ValueType {
        switch self {
        case let .success(value): return value
        case let .failure(error): return f(error)
        }
    }
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
    return { result in
        switch result {
        case .success(let value): return .success(f(value))
        case .failure(let error): return .failure(error)
        }
    }
}

func flatMap<A, B, E>(_ f: @escaping (A) -> Result<B, E>) -> (Result<A, E>) -> Result<B, E> {
    return { result in
        switch result {
        case .success(let value): return f(value)
        case .failure(let error): return .failure(error)
        }
    }
}

func resultFromOptional<V, E>(with error: @escaping @autoclosure () -> E) -> (_ value: V?) -> Result<V, E> {
    return { value in
        if let value = value {
            return .success(value)
        } else {
            return .failure(error())
        }
    }
}

func resultFromThrowing<V>(throwing: () throws -> V) -> Result<V, Error> {
    do {
        return .success(try throwing())
    } catch {
        return .failure(error)
    }
}
