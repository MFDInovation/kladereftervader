//
//  ViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
// Viewcontroller responsible for the main view.
class MainViewController: UIViewController {
    
    let smhi = SMHIAPI()
    let gps = GPS()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var imagePageView: ImagePageViewController? = nil
    var currentClothes = Clothing.errorGPS
    var currentWeather: Weather?
    var weatherAnimation = WeatherAnimation()
    var lastLoadTime = Date.distantPast
    
    //Function only for demo purposes
    var demoCounter = 0;
    @IBAction func demobuttonPressed(_ sender: Any) {
        var season:Season!
        var temperature:Double = 0
        var rain:Double = 0
        switch demoCounter/15 {
        case 0:
            season = .winter
            temperature = Double(-3 - demoCounter*2)
        case 1:
            season = .spring
            temperature = Double(demoCounter - 15)
        case 2:
            season = .summer
            temperature = Double(demoCounter - 13)
        default:
            season = .autumn
            temperature = 15 - Double(demoCounter - 43)
        }
        let symbol = WeatherSymbol.create(rawValue: demoCounter%15+1, season: season)!
        switch symbol{
        case .Lightsleet: if temperature < 5 && temperature > -2 { rain = 3 }
        case .Snowshowers: if temperature < 0 { rain = 3 }
        case .Rainshowers: if temperature > 0 { rain = 1 }
        case .Rain: if temperature > 0 { rain = 5 }
        case .Snowfall: if temperature < 0 { rain = 10 }
        case .Sleet: if temperature < 5 && temperature > -2 { rain = 3 }
        case .Thunder:
            rain = 20
            temperature = max(temperature,2)
            if season == .winter{
                demoCounter+=1;
                return demobuttonPressed(sender)
            }
        case .Thunderstorm:
            rain = 10
            temperature = max(temperature,2)
            if season == .winter{
                demoCounter+=1;
                return demobuttonPressed(sender)
            }
        default: break;
        }
        let windSpeed = Double(demoCounter%15)/7.0;
        currentWeather = Weather(symbol: symbol, temperature: temperature, rainfall: rain, windSpeed: windSpeed)
        currentClothes = Clothing.create(from: currentWeather!)
        self.showWeather(currentWeather)
        print(currentWeather?.symbol.stringRepresentation() ?? "")
        demoCounter = (demoCounter + 1)%(15*4)
    }
    @IBAction func feedbackPressed(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://www.mfd.se/kladereftervader")!)

    }
    
    // Find the embedded pageview by catching its segueue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ImagePageViewController{
            self.imagePageView = destination
        } else if let navigationController = segue.destination as? UINavigationController,
            let destination = navigationController.viewControllers.first as? ClothesTableViewController {
            destination.currentClothes = currentClothes
            weatherAnimation.clear()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather()
    }
    
    //Loads and displays the current weather
    func loadWeather(){
        imageView.image = nil
        imagePageView?.setImages([])
        temperatureLabel.text = ""
        activityIndicator.startAnimating()
        gps.findLocation {
            switch $0{
            case .success(let location):
                self.smhi.getUpcomingWeather(location: location) { result in
                    OperationQueue.main.addOperation {
                        self.weatherAnimation.clear()
                        self.activityIndicator.stopAnimating()
                        switch result {
                        case .success(let weather):
                            self.lastLoadTime = Date()
                            self.currentWeather = weather
                            self.currentClothes = Clothing.create(from: weather)
                            self.showWeather(weather)
                        case .error(_):
                            self.currentWeather = nil
                            self.currentClothes = .errorNetwork
                            self.showWeather(self.currentWeather)
                        }
                    }
                }
            case .error(_):
                OperationQueue.main.addOperation {
                    self.activityIndicator.stopAnimating()
                    self.currentWeather = nil
                    self.currentClothes = .errorNetwork
                    self.showWeather(self.currentWeather)
                }
            }
        }
    }
    
    func showWeather(_ weather: Weather?, animated:Bool=true) {
        if let weather = weather{
            temperatureLabel.text = "\(Int(round(weather.temperature)))°"
            
            imageView.accessibilityLabel = weather.symbol.stringRepresentation()
            imageView.isAccessibilityElement = true
            containerView.accessibilityLabel = currentClothes.rawValue
            containerView.isAccessibilityElement = true
            
            imageView.image = weather.symbol.imageRepresentation()
            
            var images = ClothesImageHandler.shared.getImagesFor(currentClothes)
            if images.count == 0 { images = [currentClothes.image]}
            imagePageView?.setImages(images, animated:animated)
            restartAnimations()
        }else{
            temperatureLabel.text = ""
            imageView.isAccessibilityElement = false
            containerView.accessibilityLabel = currentClothes.rawValue
            containerView.isAccessibilityElement = true
            imageView.image = nil
            
            var images = ClothesImageHandler.shared.getImagesFor(currentClothes)
            if images.count == 0 { images = [currentClothes.image]}
            imagePageView?.setImages(images, animated:animated)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let currentWeather = currentWeather{
            var images = ClothesImageHandler.shared.getImagesFor(Clothing.create(from: currentWeather))
            if images.count == 0 { images = [currentClothes.image]}
            imagePageView?.setImages(images, animated:animated)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Date().timeIntervalSince(lastLoadTime) > 30*60 {
            loadWeather()
        }else{
            if let currentWeather = currentWeather{
                showWeather(currentWeather, animated: false)
            }
        }
    }
    public func stopAnimations(){
        weatherAnimation.clear()
    }
    public func restartAnimations(){
        stopAnimations()
        if let currentWeather = currentWeather{
            weatherAnimation.create(in: imageView, for: currentWeather)
        }
    }
    
}

