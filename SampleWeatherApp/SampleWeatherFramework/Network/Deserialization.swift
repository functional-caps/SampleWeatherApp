//
//  Deserialization.swift
//  SampleWeatherApp
//
//  Created by Private Siejkowski on 05/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

struct ErrorResponse: Decodable, Equatable {
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
    let deg: Double
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
    let cod: String
}

//{\"dt\":1554649200,\"main\":{\"temp\":290.02,\"temp_min\":287.891,\"temp_max\":290.02,\"pressure\":1007.46,\"sea_level\":1007.46,\"grnd_level\":995.66,\"humidity\":68,\"temp_kf\":2.13},\"weather\":[{\"id\":800,\"main\":\"Clear\",\"description\":\"clear sky\",\"icon\":\"01d\"}],\"clouds\":{\"all\":0},\"wind\":{\"speed\":2.16,\"deg\":3.00305},\"sys\":{\"pod\":\"d\"},\"dt_txt\":\"2019-04-07 15:00:00\"}

struct MainForecastWeather: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Double
    let sea_level: Double
    let grnd_level: Double
    let humidity: Int
    let temp_kf: Double
}

struct ForecastSys: Decodable {
    let pod: String
}

struct Rain: Decodable {
//    let 3h: String
}

struct ForecastSample: Decodable {
    let dt: Int
    let main: MainForecastWeather
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let sys: ForecastSys
    let dt_txt: String
    let rain: Rain?
}

struct ForecastCity: Decodable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
    let population: Int
}

struct ForecastWeather: Decodable {
    let cod: String
    let message: Double
    let cnt: Int
    let list: [ForecastSample]
    let city: ForecastCity
}

func deserialize<T>(into: T.Type) -> (_ data: Data) -> Result<T, APIError> where T: Decodable {
    return { data in
        resultFromThrowing { try JSONDecoder().decode(T.self, from: data) }.mapError { error in
            APIError.couldNotDeserialize(data, becauseOf: error)
        }
    }
}
