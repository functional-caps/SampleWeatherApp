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
        
    private var currentReturn: Parallel<(Data?, URLResponse?, Error?), URLSessionDataTaskInterface> =
        Parallel { completion in
            let task = URLSessionDataTaskMock()
            task.callOnResume = { completion((nil,nil,nil)) }
            return task
        }
    
    func `return`(response: String) {
        currentReturn = Parallel { completion in
            let task = URLSessionDataTaskMock()
            task.callOnResume = {
                let completionArgs: (Data?, URLResponse?, Error?) = (
                    response.data(using: .utf8)!, nil, nil
                )
                completion(completionArgs)
            }
            return task
        }
    }
    
    func `return`(error: Error) {
        currentReturn = Parallel { completion in
            let task = URLSessionDataTaskMock()
            task.callOnResume = {
                let completionArgs: (Data?, URLResponse?, Error?) = (
                    nil, nil, error
                )
                completion(completionArgs)
            }
            return task
        }
    }
    
    func data(with request: URLRequest) -> Parallel<(Data?, URLResponse?, Error?), URLSessionDataTaskInterface> {
        return currentReturn
    }
    
}
