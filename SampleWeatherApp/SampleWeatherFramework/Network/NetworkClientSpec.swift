//
//  NetworkClientSpec.swift
//  NetworkClientSpec
//
//  Created by Kamil Kosowski on 15.07.2018.
//  Copyright © 2018 Kamil Kosowski. All rights reserved.
//

import Quick
import Nimble
@testable import SampleWeatherFramework

class NetworkClientSpec: QuickSpec { override func spec() {
    
    describe("APIError") {
        
    }
    
    describe("fetchCurrentWeather method") {
        context("when called") {
            it("should return ") {
                waitUntil(timeout: 2) { done in
                    
                    fetchCurrentWeather(for: .warsaw).run {
                        switch $0 {
                        case .success(let value):
                            print(value)
                        case .failure(let error):
                            print(error)
                        }
                        done()
                    }
                    
                }
            }
        }
    }
}}
