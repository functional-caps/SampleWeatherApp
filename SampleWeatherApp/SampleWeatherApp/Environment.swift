//
//  Environment.swift
//  SampleWeatherApp
//
//  Created by Siejkowski on 01/02/2019.
//  Copyright © 2019 Kamil Kosowski. All rights reserved.
//

import Foundation

let Current = Environment()

struct Environment {
    
    let session: URLSessionInterface = URLSessionProvider.production
    
    let sampleCurrentWeatherResponse = "{\"coord\":{\"lon\":21.01,\"lat\":52.23},\"weather\":[{\"id\":803,\"main\":\"Clouds\",\"description\":\"broken clouds\",\"icon\":\"04n\"}],\"base\":\"stations\",\"main\":{\"temp\":273.62,\"pressure\":1025,\"humidity\":86,\"temp_min\":273.15,\"temp_max\":274.15},\"visibility\":10000,\"wind\":{\"speed\":2.6,\"deg\":250},\"clouds\":{\"all\":75},\"dt\":1549425600,\"sys\":{\"type\":1,\"id\":1713,\"message\":0.0038,\"country\":\"PL\",\"sunrise\":1549433321,\"sunset\":1549467125},\"id\":756135,\"name\":\"Warsaw\",\"cod\":200}"
}
