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

enum City: String {
    case warsaw = "Warsaw"
}

//func fetchCurrentWeather(using environment: Environment = Current,
//                         for city: City,
//                         completion: @escaping (Result<Data, APIError>) -> Void) {
//
//    currentWeatherRequest(for: city)
//    |> map { urlRequest in
//        environment.session.data(with: urlRequest) { data, _, error in
//            data |> resultFromOptional(with: APIError.from(error)) |> completion
//        }
//    }
//    >>> map {
//        $0.resume()
//    }
//    >>> handleError { error in
//        completion(.failure(error))
//    }
//
//}

func fetchCurrentWeather(using environment: Environment = Current,
                         for city: City) -> Completion<Result<Data, APIError>> {
    return Completion { completion in
        currentWeatherRequest(for: city)
            |> map { urlRequest in
                environment.session.data(with: urlRequest) { data, _, error in
                    data |> resultFromOptional(with: APIError.from(error)) |> completion
                }
            }
            >>> map {
                $0.resume()
            }
            >>> handleError { error in
                completion(.failure(error))
        }
    }
}


// MARK: - Implementation

fileprivate func currentWeatherUrlString(for city: City) -> String {
    return "https://api.openweathermap.org/data/2.5/weather?q=\(city.rawValue)"
}

fileprivate func addAuthentication(to urlString: String) -> String {
    let apiKey = "f3231a3330c9be339f21f5c969a5fefc"
    return "\(urlString)&appid=\(apiKey)"
}

fileprivate func currentWeatherUrl(for city: City) -> Result<URL, APIError> {
    return city |> currentWeatherUrlString >>> addAuthentication >>> URL.init(string:) >>> resultFromOptional(with: APIError.malformedURL)
}

fileprivate func urlRequest(url: URL) -> URLRequest {
    return URLRequest(url: url)
}

fileprivate func currentWeatherRequest(for city: City) -> Result<URLRequest, APIError> {
    return city |> currentWeatherUrl >>> map(urlRequest)
}


// TODO
// 1. Zrobić jeden request funkcyjnie
// 2. Zrobić pusty ViewController i najprostszy ViewModel (o ile trzeba, może ViewModel też może być funkcją?)
// 3. Zrobić Environment i użyć go np. do podawania URLSession

// Szkic z funkcjami

//        let request = addHeaders >>> addBody >>> setMethod // (Request) -> Request
//
//        iosify // (Request) -> URLRequest
//
//        service // (URLRequest) -> Data
//
//        deserializer // (Data) -> JSON
//
//        let fetchingForecast = request >>> iosify >>> service(APIconf) >>> deserializer(Forecast) // (Request) -> JSON
//
//        let data = Request() |> fetchingForecast // JSON

// Szkic z konfiguracjami na enumach? Co może być sensowną konfiguracją, a co powinno być funkcją?

//        request >>> iosify >>> service(APIconf) /* (Request) -> (DeserializationVariant -> Data) */
//            >>> deserializer(Forecast) // one of three variants: foo: (Data) -> Int, bar: (Data) -> String, baz: (Data) -> Void

// Może taki patern jako fileprivate
