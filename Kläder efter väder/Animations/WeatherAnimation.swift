//
//  WeatherAnimation.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-12-02.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit

class WeatherAnimation{
    private var weatherAnimations = [StoppableAnimation]()
    private var layer: CALayer?
    func clear() {
        weatherAnimations.forEach{$0.stop()}
        weatherAnimations = []
        layer?.removeAllAnimations()
    }
    func create(in view:UIView, for weather:Weather){
        if weather.rainfall < 0.1 { return }
        
        // make sure the animation is visible, even for low amounts
        let rainfall = max( weather.rainfall, 0.7)
        let windSpeed = min(weather.windSpeed/3,2)
        
        switch weather.symbol {
            case .Rain, .Rainshowers:
                create(in: view, intensity: Int(min(rainfall*10, 100.0)), wind: windSpeed, particle: #imageLiteral(resourceName: "rain"), time: 0.4)
            case .Snowfall, .Snowshowers:
                create(in: view, intensity: Int(min(rainfall*20, 200.0)), wind: windSpeed, particle: #imageLiteral(resourceName: "snow"), time: 6)
            case .Sleet, .Lightsleet:
                create(in: view, intensity: Int(min(rainfall*5, 50.0)), wind: windSpeed, particle: #imageLiteral(resourceName: "rain"), time: 0.4)
                create(in: view, intensity: Int(min(rainfall*10, 100.0)), wind: windSpeed, particle: #imageLiteral(resourceName: "snow"), time: 6)
            case .Thunder, .Thunderstorm:
                for _ in 1..<5 {
                    let animation = ThunderAnimation()
                    animation.create(view: view)
                    weatherAnimations.append(animation)
                }
                fallthrough
            default:
                let particle = weather.temperature > 0 ? #imageLiteral(resourceName: "rain"): #imageLiteral(resourceName: "snow")
                let time = weather.temperature > 0 ? 0.4 : 6
                create(in: view, intensity: Int(min(rainfall*15, 100.0)), wind: windSpeed, particle: particle, time: Double(time))
        }
        
        
    }
    func create(in view: UIView, intensity:Int, wind:Double, particle: UIImage, time:Double){
        self.layer = view.layer
        for _ in 0..<intensity {
            let animation = AnimationParticle()
            animation.create(view: view, wind: wind, particle: particle, time: time)
            weatherAnimations.append(animation)
        }
        
    }
}

protocol StoppableAnimation {
    func stop()
}


