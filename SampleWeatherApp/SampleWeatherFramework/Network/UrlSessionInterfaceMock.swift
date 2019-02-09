//
//  UrlSessionInterfaceMock.swift
//  SampleWeatherFrameworkTests
//
//  Created by Private Siejkowski on 09/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

final class URLSessionDataTaskMock: URLSessionDataTaskInterface {
    
    var callOnResume: () -> Void = {}
    
    func resume() { callOnResume() }
}

final class URLSessionMock: URLSessionInterface {
    
    var sampleCurrentWeatherResponse: String {
        return "{\"coord\":{\"lon\":21.01,\"lat\":52.23},\"weather\":[{\"id\":803,\"main\":\"Clouds\",\"description\":\"broken clouds\",\"icon\":\"04n\"}],\"base\":\"stations\",\"main\":{\"temp\":273.62,\"pressure\":1025,\"humidity\":86,\"temp_min\":273.15,\"temp_max\":274.15},\"visibility\":10000,\"wind\":{\"speed\":2.6,\"deg\":250},\"clouds\":{\"all\":75},\"dt\":1549425600,\"sys\":{\"type\":1,\"id\":1713,\"message\":0.0038,\"country\":\"PL\",\"sunrise\":1549433321,\"sunset\":1549467125},\"id\":756135,\"name\":\"Warszawa\",\"cod\":200}"
    }
    
    func data(with request: URLRequest) -> Parallel<(Data?, URLResponse?, Error?), URLSessionDataTaskInterface> {
        return Parallel { completion in
            let task = URLSessionDataTaskMock()
            task.callOnResume = {
                let completionArgs: (Data?, URLResponse?, Error?) = (
                    self.sampleCurrentWeatherResponse.data(using: .utf8)!, nil, nil
                )
                completion(completionArgs)
            }
            return task
        }
    }
    
}
