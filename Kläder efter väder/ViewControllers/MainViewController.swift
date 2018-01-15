//
//  ViewController.swift
//  Kläder efter väder
//
//  Created by Paul Griffin on 2016-10-31.
//  Copyright © 2016 Knowit. All rights reserved.
//

import UIKit
// View controller responsible for the main view.
class MainViewController: UIViewController {

    let smhi = SMHIAPI()
    let gps = GPS()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var imagesViewController: ImagesViewController? = nil
    var currentWeather: Weather?
    var weatherAnimation = WeatherAnimation()
    var lastLoadTime = Date.distantPast
    var isLoadingWeather = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        temperatureLabel.backgroundColor = UIColor.init(white: 0.9, alpha: 1)
        loadAccessibility()
        addObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWeatherIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - Layout

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        if let width = imageView.image?.size.width, let height = imageView.image?.size.height {
            let aspect = height/width
            if aspect > 1.0 {
                let offset = (imageView.bounds.size.width*aspect - imageView.bounds.size.height)/2.0
                imageView.transform = CGAffineTransform(translationX: 0, y: (offset > 0 ? offset : 0))
            }
        }
    }


    // MARK: - Background / Foreground

    @objc private func appDidBecomeActive() {
        restartAnimations()
        loadWeatherIfNeeded()
    }

    @objc private func appWillResignActive() {
        stopAnimations()
    }


    // MARK: - Weather
    
    func loadWeatherIfNeeded() {
        if isLoadingWeather {
            return
        }
        
        if Date().timeIntervalSince(lastLoadTime) > 30*60 {
            loadWeather()
        } else {
            if let currentWeather = currentWeather {
                showWeather(currentWeather, animated: false)
            }
        }
    }
    
    //Loads and displays the current weather
    func loadWeather() {
        imageView.image = nil
        temperatureLabel.text = ""
        activityIndicator.startAnimating()
        isLoadingWeather = true
        
        gps.findLocation {
            switch $0 {
                case .success(let location):
                    self.smhi.getUpcomingWeather(location: location) { result in
                        OperationQueue.main.addOperation {
                            self.weatherAnimation.clear()
                            self.activityIndicator.stopAnimating()
                            switch result {
                                case .success(let weather):
                                    self.lastLoadTime = Date()
                                    self.currentWeather = weather
                                    self.showWeather(weather)
                                    self.isLoadingWeather = false
                                case .error(_):
                                    self.currentWeather = nil
                                    // Reset imagesViewController
                                    self.showWeather(self.currentWeather)
                                    self.imagesViewController?.showNetworkError()
                                    self.isLoadingWeather = false
                            }
                        }
                    }
                case .error(_):
                    OperationQueue.main.addOperation {
                        self.activityIndicator.stopAnimating()
                        self.currentWeather = nil
                        self.showWeather(self.currentWeather)
                        self.imagesViewController?.showGPSError()
                        self.isLoadingWeather = false
                    }
            }
        }
    }

    private func updateTemperatureLabelForWeather(_ weather: Weather) {
        temperatureLabel.text = "\(Int(round(weather.temperature)))°"
    }

    private func resetTemperatureLabel() {
        temperatureLabel.text = ""
    }
    
    private func resetImages(_ animated: Bool) {
        imageView.isAccessibilityElement = false
        imageView.image = nil
    }
    
    func showWeather(_ weather: Weather?, animated:Bool=true) {
        if let weather = weather {
            imageView.image = weather.symbol.imageRepresentation()
            updateTemperatureLabelForWeather(weather)
            updateAccessibilityLabelsForWeather(weather)
            restartAnimations()
            imagesViewController?.weather = weather
        } else {
            resetTemperatureLabel()
            resetImages(animated)
            imagesViewController?.weather = nil
//            containerView.accessibilityLabel = currentClothes.rawValue
        }
    }


    // MARK: - Animations

    public func stopAnimations() {
        weatherAnimation.clear()
    }
    
    public func restartAnimations() {
        stopAnimations()
        if let currentWeather = currentWeather {
            weatherAnimation.create(in: imageView, for: currentWeather)
        }
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedImagesVC" {
            let destination = segue.destination as? ImagesViewController
            imagesViewController = destination
        }
    }


    // MARK: - Observers

    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: .UIApplicationWillResignActive, object: nil)
    }


    // MARK: - Accessibility

    private func loadAccessibility() {
        if #available(iOS 10.0, *) {
            imageView.isAccessibilityElement = true

            temperatureLabel.adjustsFontForContentSizeCategory = true
            temperatureLabel.isAccessibilityElement = true
        } else {
            // Fallback on earlier versions
        }
    }

    private func updateAccessibilityLabelsForWeather(_ weather: Weather) {
        imageView.accessibilityLabel = weather.symbol.stringRepresentation()
        temperatureLabel.accessibilityLabel = "Temperatur: \(Int(round(weather.temperature)))°"
    }
}
