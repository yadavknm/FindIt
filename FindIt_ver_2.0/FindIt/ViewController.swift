//
//  ViewController.swift
//  FindIt
//
//  Created by Yadav Murthy on 4/12/17.
//  Copyright © 2017 Mac. All rights reserved.
//


import UIKit
import GooglePlacePicker
import CoreLocation
import GoogleMaps
import MapKit
import AVFoundation




class ViewController: UIViewController, CLLocationManagerDelegate, WeatherGetterDelegate{
    
    @IBOutlet var weatherLabel: UILabel!
    var locationManager: CLLocationManager!
    var latitude : CLLocationDegrees!
    var longitude : CLLocationDegrees!
    var category: String!
    var catRow: Int!
    var weatherGetter: WeatherGetter!
    var mapItems: [MKMapItem]!
    var catVideo: String!
    
    @IBOutlet weak var wv: UIWebView!
    
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var cloudCoverLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    
    var weather: WeatherGetter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cloud.png")!)
        
        // loading the video for the categories
        loadYoutube(videoID: "\(catVideo)")
        
        // extracting the current weather information
        weather = WeatherGetter(delegate: self)
        
        // determining the current location
        determineMyCurrentLocation()
        
        cityLabel.alpha = 0
        descriptionLabel.alpha = 0
        temperatureLabel.alpha = 0
        cloudCoverLabel.alpha = 0
        windLabel.alpha = 0
        humidityLabel.alpha = 0
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        cityLabel.center.x -= view.bounds.width
        descriptionLabel.center.x += view.bounds.width
        temperatureLabel.center.x -= view.bounds.width
        cloudCoverLabel.center.x += view.bounds.width
        windLabel.center.x -= view.bounds.width
        humidityLabel.center.x += view.bounds.width
        
        // animate it from the left to the right and right to left
        UIView.animateWithDuration(0.6, delay: 0, options: [.CurveEaseOut], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        cityLabel.alpha = 1
        descriptionLabel.alpha = 1
        temperatureLabel.alpha = 1
        cloudCoverLabel.alpha = 1
        windLabel.alpha = 1
        humidityLabel.alpha = 1
        
    }
    
    // On clicking proceed button, the Apple Maps interface is launched
    @IBAction func proceedbutton(button: UIButton){
        if mapItems == nil{
            self.showSimpleAlert(title: "No Current Location", message: "Unable to retrieve current location. Please check your settings and try again")
        }
        else{
            MKMapItem.openMapsWithItems(mapItems, launchOptions: nil)
        }
    }
    
    
    func determineMyCurrentLocation(){
        print(#function)
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    // obtaining the current latitude and longitude
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        let location: CLLocationCoordinate2D = (manager.location?.coordinate)!
        latitude = location.latitude
        longitude = location.longitude
        weather.getWeather(latitude, long: longitude)
        fetchPlacesNearCoordinate(latitude, long: longitude)
        manager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(#function)
        print("Error \(error)")
    }
    
    
    // Google Plaes API is called to extract the information in JSON format
    func fetchPlacesNearCoordinate(lat: CLLocationDegrees,long: CLLocationDegrees)
    {

        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=1000&type=\(category)&keyword=\(category)&key=AIzaSyD0862g64lX3ElcCQ7-yK-XKShAVtgWLxU"
        let encodedStr = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        guard let url = NSURL(string: encodedStr!) else{
            print("Error")
            return
        }
        
        let urlReq = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let task = session.dataTaskWithRequest(urlReq){
            (data,response,error)->Void in
            
            if let jsonData = data{
                self.mapItems = self.parseFromData(jsonData)
                
            }
            else if let reqError = error{
                print("\(reqError)")
            }
            else{
                print("Unexpectederror")
            }
        }
        task.resume()
    }
    
    // parsing the JSON data
    func parseFromData(data : NSData) -> [MKMapItem] {
        var mapItems = [MKMapItem]()
        
        do{
            let jsonObj : AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! NSDictionary
            let results = jsonObj["results"] as! Array<NSDictionary>
            
            for result in results {
                
                let name = result["name"] as! String
                
                var coordinate : CLLocationCoordinate2D!
                
                if let geometry = result["geometry"] as? NSDictionary {
                    if let location = geometry["location"] as? NSDictionary {
                        let lat = location["lat"] as! CLLocationDegrees
                        let long = location["lng"] as! CLLocationDegrees
                        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        
                        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                        let mapItem = MKMapItem(placemark: placemark)
                        mapItem.name = name
                        mapItems.append(mapItem)
                    }
                }
            }
            
        }catch{
            print("error")
        }
        
        return mapItems
    }
    
    // This method is called asynchronously, which means it won't execute in the main queue.
    // ALl UI code needs to execute in the main queue, which is why we're wrapping the code
    // that updates all the labels in a dispatch_async() call.
    func didGetWeather(weather: Weather) {
        dispatch_async(dispatch_get_main_queue()) {
            self.cityLabel.text = "City: " + weather.city
            self.descriptionLabel.text = "Weather: " + weather.weatherDescription
            self.temperatureLabel.text = "Temperature: \(Int(round(weather.tempFahrenheit)))°F"
            self.cloudCoverLabel.text = "Cloud Cover: \(weather.cloudCover)%"
            self.windLabel.text = "Wind Speed: \(weather.windSpeed) m/s"
            self.humidityLabel.text = "Humidity: \(weather.humidity)%"
            
            let synth = AVSpeechSynthesizer()
            var myUtterance = AVSpeechUtterance(string: "")
            let speak = "Today's " + "\(self.temperatureLabel.text!)"
            myUtterance = AVSpeechUtterance(string: speak)
            myUtterance.rate = 0.5
            synth.speakUtterance(myUtterance)
        }
        
    }
    
    // This method is called asynchronously, which means it won't execute in the main queue.
    // ALl UI code needs to execute in the main queue, which is why we're wrapping the call
    // to showSimpleAlert(title:message:) in a dispatch_async() call.
    func didNotGetWeather(error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showSimpleAlert(title: "Can't get the weather",
                                 message: "The weather service isn't responding.")
        }
        print("didNotGetWeather error: \(error)")
    }
    
    // alert functionality when the location services are disabled
    func showSimpleAlert(title title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .Default,
            handler: nil
        )
        alert.addAction(okAction)
        presentViewController(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    // loading the video for the category
    func loadYoutube(videoID videoID:String) {
        guard
            let youtubeURL = NSURL(string: "https://www.youtube.com/embed/\(videoID)")
            else { return }
        wv.loadRequest( NSURLRequest(URL: youtubeURL) )
    }
    
    
}