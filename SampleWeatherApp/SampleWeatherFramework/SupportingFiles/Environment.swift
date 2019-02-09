//
//  Environment.swift
//  SampleWeatherApp
//
//  Created by Siejkowski on 01/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

let isInProduction = NSClassFromString("XCTestCase") == nil

let Current: Environment = isInProduction ? .production : .mock

struct Environment {
    
    private enum Variant {
        case production
        case mock
    }
    
    static var production: Environment = .init(variant: .production)
    
    static var mock: Environment = .init(variant: .mock)
    
    let session: URLSessionInterface
    
    private init(variant: Variant) {
        switch variant {
        case .production:
            session = URLSessionProvider.production
        case .mock:
            session = URLSessionProvider.mock
        }
    }
}
