//
//  Weather.swift
//  plantR_ios
//
//  Created by Rabissoni on 03/04/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct Weather: Decodable {
    let weather: [WeatherDesc]
    let main: Main
    let wind: Wind
}

struct WeatherDesc: Decodable {
    let main: String
    let cod: String?
}

struct Main: Decodable {
    let humidity: Int
    let temp_min: Float
    let temp_max: Float
    let temp: Float
    let pressure: Float
}

struct Wind: Decodable {
    let speed: Float
}

class GetWeather {
    let openWeatherMapBaseURL = "https://api.openweathermap.org/data/2.5/weather?"
    let openWeatherMapAPIKey = "a231c70247581b21d3fd566f1fd91818"
    var countrycode = ""

    func getWeatherCity(ZIP: String, countryCode: String, completion: @escaping (Weather?) -> Void) {

            var urlStr = "\(self.openWeatherMapBaseURL)&zip=\(ZIP),\(countryCode)&appid=\(self.openWeatherMapAPIKey)"
            let weatherRequestURL = URL(string: urlStr)

            guard var weatherRURL = weatherRequestURL else {
                print("JE SORS ICI")
                return
                
            }
            URLSession.shared.dataTask(with: weatherRURL) { (data, _, _) in
                guard let data = data else { return }
                do {
                    print("DATA:\(data)")
                    let weather = try JSONDecoder().decode(Weather.self, from: data)
                    print("ICI =>")
                    print(weather)
                    completion(weather)
                    return
                } catch let jsonError {
                    print("Error Json: ", jsonError)
                    completion(nil)
                    return
                }
            }.resume()

    }
}
