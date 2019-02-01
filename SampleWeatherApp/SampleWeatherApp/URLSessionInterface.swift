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
    func data(with request: URLRequest,
              completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskInterface
}

extension URLSession: URLSessionInterface {
    func data(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskInterface {
        return dataTask(with: request, completionHandler: completionHandler)
    }
}

enum URLSessionProvider {
    static var production: URLSessionInterface { return URLSession.shared }
}
