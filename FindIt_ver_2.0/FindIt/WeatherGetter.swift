//
//  WeatherGetter.swift
//  FindIt
//
//  Created by Yadav Murthy on 4/21/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import CoreLocation

// delegate for Weather functionality
protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: NSError)
}

// Extracting the Weather information from the OpenWeatherMap API
class WeatherGetter {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "af6a9fb7c399e876bf8804b4b1d2a995"
    var temperature: Float!
    var humidity: Int!
    var pressure: Int!
    var windDirection: String!
    var windSpeed: Float!
    
    private var delegate: WeatherGetterDelegate
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    
    func getWeather(lat: CLLocationDegrees, long: CLLocationDegrees) {
        
        let session = NSURLSession.sharedSession()
        var weatherObj: Weather!
        
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(long)")!
        
        // The data task retrieves the data.
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                self.delegate.didNotGetWeather(error)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                do {
                    // convert that data into a Swift dictionary
                    let weather = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    weatherObj = Weather(weatherData: weather)
                    self.delegate.didGetWeather(weatherObj)
                    
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(jsonError)
                }
            }
            
        }
        
        dataTask.resume()
    }
    
}