//
//  Result+ParallelTransformers.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 09/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

extension Result {
    
    func map<A, B, C>(_ f: @escaping (A) -> C) -> Result<Parallel<C, B>, ErrorType> where ValueType == Parallel<A, B> {
        return map { $0.map(f) }
    }
    
}
