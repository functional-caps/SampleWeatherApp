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
    
    let sampleResponse = "{\"coord\":{\"lon\":21.01,\"lat\":52.23},\"weather\":[{\"id\":803,\"main\":\"Clouds\",\"description\":\"broken clouds\",\"icon\":\"04n\"}],\"base\":\"stations\",\"main\":{\"temp\":273.62,\"pressure\":1025,\"humidity\":86,\"temp_min\":273.15,\"temp_max\":274.15},\"visibility\":10000,\"wind\":{\"speed\":2.6,\"deg\":250},\"clouds\":{\"all\":75},\"dt\":1549425600,\"sys\":{\"type\":1,\"id\":1713,\"message\":0.0038,\"country\":\"PL\",\"sunrise\":1549433321,\"sunset\":1549467125},\"id\":756135,\"name\":\"Warszawa\",\"cod\":200}"
    
    describe("APIError") {
        context("when created from URLError") {
            it("should be of case urlSessionError") {
                expect({
                    guard case .urlSessionError(let urlError) = APIError.from(URLError(.networkConnectionLost)) else {
                        return .failed(reason: "APIError is not .urlSessionError")
                    }
                    guard urlError.code == .networkConnectionLost else {
                        return .failed(reason: "URLError is of wrong kind")
                    }
                    return .succeeded
                }).to(succeed())
            }
        }
        
        context("when created from error other then URLError") {
            it("should be of case unknownError") {
                expect({
                    guard case .unknownError = APIError.from(nil) else {
                        return .failed(reason: "APIError is not .unknownError")
                    }
                    return .succeeded
                }).to(succeed())
            }
        }
        
        context("when created from no error") {
            it("should be of case unknownError") {
                expect({
                    guard case .unknownError = APIError.from(nil) else {
                        return .failed(reason: "APIError is not .unknownError")
                    }
                    return .succeeded
                }).to(succeed())
            }
        }
    }
    
    describe("fetchCurrentWeather method") {
        context("when called") {
            context("provided URLSession will return response") {
            
                it("should result with this response") {
                    // given
                    URLSessionProvider.internalMock.return(response: sampleResponse)
                    var result: Result<Data, APIError>? = nil
                    
                    // when
                    fetchCurrentWeather(for: .warsaw).run { operationResult in
                        result = operationResult
                    }
                    
                    // then
                    expect(result).toEventuallyNot(beNil())
                    switch result {
                    case .success(let data)?:
                        let actualResponse = String(data: data, encoding: .utf8)
                        expect(actualResponse).toNot(beNil())
                        expect(actualResponse).to(equal(sampleResponse))
                    case .failure(let error)?:
                        fail("expected sample response, not error: \(error)")
                    case nil: fail("expected sample response, not nil")
                    }
                }
            }
            
            context("provided URLSession will return error") {
                it("should result with this error") {
                    // given
                    URLSessionProvider.internalMock.return(error: URLError(.networkConnectionLost))
                    var result: Result<Data, APIError>? = nil
                    
                    // when
                    fetchCurrentWeather(for: .warsaw).run { operationResult in
                        result = operationResult
                    }
                    
                    // then
                    expect(result).toEventuallyNot(beNil())
                    switch result {
                    case .success(let data)?:
                        fail("expected error, not sample response: \(String(describing: String(data: data, encoding: .utf8)))")
                    case .failure(APIError.urlSessionError(let urlError))?:
                        expect(urlError.code).to(equal(URLError.Code.networkConnectionLost))
                    case .failure?: fail("wrong error received")
                    case nil: fail("expected error, not nil")
                    }
                }
            }
        }
    }
}}
