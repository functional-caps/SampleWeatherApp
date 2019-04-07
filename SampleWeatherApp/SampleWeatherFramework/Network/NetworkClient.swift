//
//  NetworkClient.swift
//  SampleWeatherApp
//
//  Created by Siejkowski on 01/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

// MARK: - Public API

enum APIError: Error {
    case unknownError
    case malformedURL
    case urlSessionError(URLError)
    case couldNotDeserialize(Data, becauseOf: Error)
    
    static func from(_ error: Error?) -> APIError {
        if let urlError = error as? URLError {
            return APIError.urlSessionError(urlError)
        } else {
            return APIError.unknownError
        }
    }
}

extension APIError: Equatable {

    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.unknownError, .unknownError), (.malformedURL, .malformedURL): return true
        case let (.urlSessionError(le), .urlSessionError(re)): return le == re
        case let (.couldNotDeserialize(ld, _), .couldNotDeserialize(rd, _)): return ld == rd
        default: return false
        }
    }
}

enum City: String {
    case warsaw = "Warsaw,pl"
}

func fetchCurrentWeather(using environment: Environment = Current,
                         for city: City) -> Completion<Result<Data, APIError>> {
    
    return currentWeatherRequest(for: city)
        .map(environment.session.data(with:))
        .map(parseResponse)
        .map(toCompletion { $0.resume() })
        .recover { error in Completion<Result<Data, APIError>> { completion in completion(.failure(error)) }}
}

func fetchForecastWeather(using environment: Environment = Current,
                          for city: City) -> Completion<Result<Data, APIError>> {
    
    return forecastWeatherRequest(for: city)
        .map(environment.session.data(with:))
        .map(parseResponse)
        .map(toCompletion { $0.resume() })
        .recover { error in Completion<Result<Data, APIError>> { completion in completion(.failure(error)) }}
}

// MARK: - Implementation

fileprivate func currentWeatherUrlString(for city: City) -> String {
    return "https://api.openweathermap.org/data/2.5/weather?q=\(city.rawValue)"
}

fileprivate func forecastWeatherUrlString(for city: City) -> String {
    return "https://api.openweathermap.org/data/2.5/forecast?q=\(city.rawValue)"
}

fileprivate func addAuthentication(to urlString: String) -> String {
    let apiKey = "f3231a3330c9be339f21f5c969a5fefc"
    return "\(urlString)&appid=\(apiKey)"
}

let toAuthenticatedUrl = addAuthentication
    >>> URL.init(string:)
    >>> resultFromOptional(with: APIError.malformedURL)
    >>> map { URLRequest.init(url: $0) }

fileprivate func currentWeatherRequest(for city: City) -> Result<URLRequest, APIError> {
    return city |> currentWeatherUrlString >>> toAuthenticatedUrl
}

fileprivate func forecastWeatherRequest(for city: City) -> Result<URLRequest, APIError> {
    return city |> forecastWeatherUrlString >>> toAuthenticatedUrl
}

fileprivate func parseResponse(data: Data?, response: URLResponse?, error: Error?) -> Result<Data, APIError> {
    return data |> resultFromOptional(with: APIError.from(error))
}