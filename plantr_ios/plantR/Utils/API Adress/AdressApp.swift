//
//  AdressApp.swift
//  plantR_ios
//
//  Created by Adison Pereira de oliveira on 01/04/2022.
//  Copyright © 2022 Agrove. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let geoAPI = try? newJSONDecoder().decode(GeoAPI.self, from: jsonData)

import Foundation

// MARK: - GeoAPI
struct GeoAPI: Codable {
    let features: [Feature]?
}

// MARK: - Feature
struct Feature: Codable {
    let properties: Properties?
}


// MARK: - Properties
struct Properties: Codable {
    let city, state, postcode: String?
    let country, country_code: String?
}



class GetAdress {
    let url = "https://api.geoapify.com/v1/geocode/autocomplete?"
    let apiKey = "98fb899cb6254d51b9e29e294af38106"
    
    func getAdressInfos(str: String) -> GeoAPI? {
        var res : GeoAPI? = nil
        let urlStr = "\(self.url)text=\(str)&apiKey=\(self.apiKey)"
        let requestURL = URL(string: urlStr)
        guard let adressURL = requestURL else {
            return nil
        }
        URLSession.shared.dataTask(with: adressURL) { (data, _, _) in
            guard let data = data else {return}
            print("addd -> in let")
            do {
                
                let geoAPI = try? JSONDecoder().decode(GeoAPI.self, from: data)
                print("addd -> after req")
                print("addd --> rez \(geoAPI)")
                res = geoAPI
                
            } catch {
                print("addd \(error)")
                return
            }
        }.resume()
        return res
    }
}
