//
//  SMHIAPI.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
import CoreLocation


struct Weather {
    var symbol: WeatherSymbol
    var temperature: Double
    var rainfall: Double
    var windSpeed: Double
    
    init(symbol: WeatherSymbol, temperature: Double, rainfall: Double, windSpeed: Double){
        self.symbol = symbol
        self.temperature = temperature
        self.rainfall = rainfall
        self.windSpeed = windSpeed
    }
    
    init?(with json:Json, start: Date, end: Date){
        
        /*symbol = .Thunder(season: .autumn)
        temperature = 14
        rainfall = 2
        windSpeed = 1
        return*/
        
        guard let timeSeries = json["timeSeries"].array else { return nil }
        
        
        var maxRainfall = -Double.infinity
        var minTemperature = Double.infinity
        var worstSymbol:WeatherSymbol? = nil
        var maxWindSpeed:Double = 0
        
        for weather in timeSeries {
            if let date = weather["validTime"].date, date > start, date < end,
                let parameters = weather["parameters"].array,
                let temperature = Weather.getValueForSymbol(json: parameters, name: "t").double,
                let rainfall = Weather.getValueForSymbol(json: parameters, name: "pmax").double,
                let symbolInteger = Weather.getValueForSymbol(json: parameters, name: "Wsymb2").num,
                let windSpeed = Weather.getValueForSymbol(json: parameters, name: "ws").double,
                let symbol = WeatherSymbol.create(rawValue: symbolInteger){
                
                if (worstSymbol == nil || worstSymbol!.priority < symbol.priority){
                    worstSymbol = symbol
                }
                maxRainfall = max(rainfall, maxRainfall)
                minTemperature = min(temperature, minTemperature)
                maxWindSpeed = max(maxWindSpeed, windSpeed)
            }
        }
        
        temperature = minTemperature
        rainfall = maxRainfall
        windSpeed = maxWindSpeed
        
        //If worstSymbol is set, we know we had at least one valid datapoint
        if let symbol = worstSymbol {
            self.symbol = symbol
        }else{
            return nil
        }
    }
    static func getValueForSymbol(json:[Json], name:String) -> Json{
        if let rainfallJson = json.first(where: {$0["name"].string == name }) {
            let rainfall = rainfallJson["values"].array?.first
            return rainfall ?? Json(object: nil)
        }
        return Json(object: nil)
    }
}

class SMHIAPI {
    let networking = Networking();
    func  weatherUrl(location: CLLocation) -> URL? {
        let lon = String(format:"%.3f", location.coordinate.longitude)
        let lat = String(format:"%.3f", location.coordinate.latitude)
        let tmp = URL(string: "http://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(lon)/lat/\(lat)/data.json")
        return tmp
    }

    func getUpcomingWeather(location: CLLocation, _ callback: @escaping (Response<Weather>) -> Void){
        let start = Date()
        let end = Date()+60*60*8
        getWeather(location: location, start: start, end: end, callback)
    }

    func getWeather(location: CLLocation, start: Date, end: Date, _ callback: @escaping (Response<Weather>) -> Void){
        networking.getJson(url: weatherUrl(location: location)!){
            switch $0 {
                case .success(let json):
                    if let weather = Weather(with: json,start: start,end: end) {
                        callback(.success(weather))
                    } else {
                        callback(.error(NSError(domain: "Weather", code: 1, userInfo: [NSLocalizedDescriptionKey:"Could not parse results from server"])))
                    }
                case .error(let error):
                    callback(.error(error))
            }
        }
    }

}
