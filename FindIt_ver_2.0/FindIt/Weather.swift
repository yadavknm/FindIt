//
//  Weather.swift
//  FindIt
//
//  Created by Yadav Narayana Murthy on 4/26/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

// Creating the Weather object
struct Weather {
    
    let city: String
    let longitude: Double
    let latitude: Double
    
    let mainWeather: String
    let weatherDescription: String
    
    // OpenWeatherMap reports temperature in Kelvin,
    // which is why we provide celsius and fahrenheit
    // computed properties.
    private let temp: Double
    var tempCelsius: Double {
        get {
            return temp - 273.15
        }
    }
    var tempFahrenheit: Double {
        get {
            return (temp - 273.15) * 1.8 + 32
        }
    }
    let humidity: Int
    let cloudCover: Int
    let windSpeed: Double
    
    // Initializing the weather information
    init(weatherData: [String: AnyObject]) {
        city = weatherData["name"] as! String
        
        let coordDict = weatherData["coord"] as! [String: AnyObject]
        longitude = coordDict["lon"] as! Double
        latitude = coordDict["lat"] as! Double
        
        let weatherDict = weatherData["weather"]![0] as! [String: AnyObject]
        
        mainWeather = weatherDict["main"] as! String
        weatherDescription = weatherDict["description"] as! String
        
        let mainDict = weatherData["main"] as! [String: AnyObject]
        temp = mainDict["temp"] as! Double
        humidity = mainDict["humidity"] as! Int
        
        cloudCover = weatherData["clouds"]!["all"] as! Int
        
        let windDict = weatherData["wind"] as! [String: AnyObject]
        windSpeed = windDict["speed"] as! Double
        
    }
    
}