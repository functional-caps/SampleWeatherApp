//
//  Parallel+ResultTransformers.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 09/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

extension Parallel {
    
    func map<VI, VO, E>(_ f: @escaping (VI) -> VO) -> Parallel<Result<VO, E>, B> where A == Result<VI, E> {
        return map { (result: Result<VI, E>) -> Result<VO, E> in result.map(f) }
    }
    
    func map<VI, VO, E>(_ f: @escaping (VI) -> Result<VO, E>) -> Parallel<Result<VO, E>, B> where A == Result<VI, E> {
        return map { (result: Result<VI, E>) -> Result<VO, E> in result.flatMap(f) }
    }
    
    func map<V, EI, EO>(_ f: @escaping (EI) -> Result<V, EO>) -> Parallel<Result<V, EO>, B> where A == Result<V, EI> {
        return map { (result: Result<V, EI>) -> Result<V, EO> in result.flatMapError(f) }
    }

}
