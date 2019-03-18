//
//  DeserializationSpec.swift
//  SampleWeatherFrameworkTests
//
//  Created by Private Siejkowski on 04/03/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import SampleWeatherFramework

class DeserializationSpec: QuickSpec { override func spec() {
    
    
    describe("Deserialization") {
        context("") {
            it("") {
                let data = """
                           { "cod": "testCod", "message": "testMessage" }
                           """.data(using: .utf8)!
                
                let result = data
                |> deserialize(into: ErrorResponse.self)
                
                expect(result).to(equal(Result<ErrorResponse, APIError>.success(ErrorResponse(cod: "testCod", message: "testMessage"))))
            }
        }
    }

}}
