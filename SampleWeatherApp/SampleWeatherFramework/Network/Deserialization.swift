//
//  Deserialization.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 05/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable {
    let cod: String
    let message: String
}

struct Coordinates: Decodable {
    let lon: Double
    let lat: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String // should be enum?
    let description: String
    let icon: String // is it base64? or enum identifier?
}

struct MainWeather: Decodable {
    let temp: Double
    let pressure: Int
    let humidity: Int
    let temp_min: Double
    let temp_max: Double
}

struct Wind: Decodable {
    let speed: Double
    let deg: Int
}

struct Clouds: Decodable {
    let all: Int
}

struct Sys: Decodable {
    let type: Int
    let id: Int
    let message: Double
    let country: String // enum?
    let sunrise: Int // Time interval
    let sunset: Int // Time interval
}

struct CurrentWeather: Decodable {
    let coord: Coordinates
    let weather: [Weather]
    let main: MainWeather
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let id: Int
    let name: String
    let cod: Int
}

func deserialize<T>(into: T.Type) -> (_ data: Data) -> Result<T, APIError> where T: Decodable {
    return { data in
        resultFromThrowing { try JSONDecoder().decode(T.self, from: data) }.mapError { error in
            APIError.couldNotDeserialize(data, becauseOf: error)
        }
    }
}
