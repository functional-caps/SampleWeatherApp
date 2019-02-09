//
//  URLSessionInterface.swift
//  SampleWeatherApp
//
//  Created by Siejkowski on 01/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

protocol URLSessionDataTaskInterface {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskInterface {}

protocol URLSessionInterface {
    func data(with request: URLRequest) -> Parallel<(Data?, URLResponse?, Error?), URLSessionDataTaskInterface>
}

extension URLSession: URLSessionInterface {
    func data(with request: URLRequest) -> Parallel<(Data?, URLResponse?, Error?), URLSessionDataTaskInterface> {
        return Parallel { completionHandler in
            return self.dataTask(with: request, completionHandler: completionHandler)
        }
    }
}

enum URLSessionProvider {
    static var production: URLSessionInterface {
        print("using production url session")
        return URLSession.shared
    }
    
    static var mock: URLSessionInterface {
        print("using mock url session")
        return URLSessionMock()
    }
}
