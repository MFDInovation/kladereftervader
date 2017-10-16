//
//  GPS.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import CoreLocation

class GPS: NSObject, CLLocationManagerDelegate{
    let locationManager = CLLocationManager()
    var callback: ((Response<CLLocation>) -> Void)? = nil
    
    func findLocation(_ callback: @escaping (Response<CLLocation>) -> Void){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
        self.callback = callback
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //locationManager.stopUpdatingLocation()
        callback?(.error(error))
        callback = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.count > 0 else { return }
        //locationManager.stopUpdatingLocation()
        callback?(.success(locations.first!))
        callback = nil
    }
    
}
