//
//  ViewController.swift
//  WeatherApp
//
//  Created by Boris Yue on 3/7/17.
//  Copyright © 2017 Boris Yue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var apparentTemperatureLabel: UILabel!
    var temperatureLabel: UILabel!
    var summaryLabel: UILabel!
    var rainLabel: UILabel!
    var circleBlurView: UIView!
    var highLowTemp: UILabel!
    var humidityLabel: UILabel!
    var windSpeed: UILabel!
    
    var rainGif = [#imageLiteral(resourceName: "rain1"),#imageLiteral(resourceName: "rain2"), #imageLiteral(resourceName: "rain3"), #imageLiteral(resourceName: "rain4"), #imageLiteral(resourceName: "rain5")]
    var sunGif = [#imageLiteral(resourceName: "sunny-1"), #imageLiteral(resourceName: "sunny-2"), #imageLiteral(resourceName: "sunny-3"), #imageLiteral(resourceName: "sunny-4"), #imageLiteral(resourceName: "sunny-5")]
    var nightGif = [#imageLiteral(resourceName: "night-1"), #imageLiteral(resourceName: "night-2"), #imageLiteral(resourceName: "night-3"), #imageLiteral(resourceName: "night-4"), #imageLiteral(resourceName: "night-5"), #imageLiteral(resourceName: "night-6"), #imageLiteral(resourceName: "night-7"), #imageLiteral(resourceName: "night-8"), #imageLiteral(resourceName: "night-9"), #imageLiteral(resourceName: "night-10")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: notificationKey), object: nil, queue: nil, using: displayData)
        displayPoweredBy()
    }
    
    func displayData(notification: Notification) {
        displayCircleBlur()
        if let data = notification.userInfo as! [String: AnyObject]? {
            if let temperatureData = data["currently"] {
                displayTemperature(fromData: temperatureData)
            }
            if let minuteData = data["minutely"] {
                displaySummary(fromData: minuteData)
                displayRainInfo(fromData: minuteData)
            }
            if let otherData = data["daily"] {
                displayOtherWeatherInfo(fromData: otherData)
            }
        }
    }
    
    func displayCircleBlur() {
        circleBlurView = UIView(frame: CGRect(x: view.frame.width / 2 - 110, y: view.frame.width / 4, width: 220, height: 220))
        circleBlurView.layer.cornerRadius = circleBlurView.frame.width / 2
        circleBlurView.clipsToBounds = true
        circleBlurView.backgroundColor = UIColor.init(white: 1, alpha: 0.25)
        circleBlurView.layer.borderWidth = 0.1
        view.addSubview(circleBlurView)
    }
    
    func displayTemperature(fromData: AnyObject) {
        let feelsLike = fromData["apparentTemperature"] as! Double
        let roundedFeelsLike = Int(round(feelsLike))
        apparentTemperatureLabel = UILabel(frame: CGRect(x: 0, y: view.frame.height / 5.1, width: 100, height: 30))
        apparentTemperatureLabel.text = "Feels like: \(roundedFeelsLike)\u{00B0}"
        apparentTemperatureLabel.font = UIFont.boldSystemFont(ofSize: 14)
        apparentTemperatureLabel.sizeToFit()
        apparentTemperatureLabel.frame.origin.x = view.frame.width / 2 - apparentTemperatureLabel.frame.width / 2
        apparentTemperatureLabel.textColor = UIColor.white
        view.addSubview(apparentTemperatureLabel)
        
        let temperature = fromData["temperature"] as! Double
        let roundedTemp = Int(round(temperature))
        temperatureLabel = UILabel(frame: CGRect(x: 0, y: apparentTemperatureLabel.frame.maxY, width: 100, height: 30))
        temperatureLabel.text = "\(roundedTemp)\u{00B0}"
        temperatureLabel.font = UIFont.systemFont(ofSize: 70)
        temperatureLabel.sizeToFit()
        temperatureLabel.frame.origin.x = view.frame.width / 2 - temperatureLabel.frame.width / 2 + 5
        temperatureLabel.textColor = UIColor.white
        view.addSubview(temperatureLabel)
    }
    
    func displaySummary(fromData: AnyObject) {
        let summary = fromData["summary"] as! String
        summaryLabel = UILabel(frame: CGRect(x: 0, y: temperatureLabel.frame.maxY + 5, width: 50, height: 30))
        summaryLabel.text = summary
        summaryLabel.font = UIFont.boldSystemFont(ofSize: 14)
        summaryLabel.sizeToFit()
        summaryLabel.frame.origin.x = view.frame.width / 2 - summaryLabel.frame.width / 2
        summaryLabel.textColor = UIColor.white
        view.addSubview(summaryLabel)
    }
    
    func displayRainInfo(fromData: AnyObject) {
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date) //getting hour to determine which gif to show
        rainLabel = UILabel(frame: CGRect(x: 0, y: circleBlurView.frame.maxY + 25, width: 50, height: 30))
        let icon = fromData["icon"] as! String
        if icon != "rain" {
            if hour > 19 || hour < 4 { //this means its night
                displayNightGif()
            } else { //means its during the day
                displaySunGif()
            }
            rainLabel.text = "Chance of Rain: 0%"
        } else {
            circleBlurView.backgroundColor = UIColor(red: 230/255, green: 172/255, blue: 0, alpha: 0.4)
            displayRainGif()
            var minutes = 0
            for minuteInfo in (fromData["data"] as! [AnyObject]) { //need to convert to [AnyObject] to iterate
                let rainProbability = minuteInfo["precipProbability"] as! Int
                if rainProbability > 0 {
                    rainLabel.text = "Chance of Rain: \(rainProbability * 100)% in \(minutes) minutes."
                    break
                }
                minutes += 1
            }
        }
        rainLabel.font = UIFont.systemFont(ofSize: 17)
        rainLabel.sizeToFit()
        rainLabel.frame.origin.x = view.frame.width / 2 - rainLabel.frame.width / 2
        rainLabel.textColor = UIColor.white
        view.addSubview(rainLabel)
    }
    
    func displayOtherWeatherInfo(fromData: AnyObject) {
        let tempData = (fromData["data"] as! [AnyObject])[0]
        
        let tempMax = Int(round(tempData["temperatureMax"] as! Double))
        let tempMin = Int(round(tempData["temperatureMin"] as! Double))
        highLowTemp = UILabel(frame: CGRect(x: 0, y: rainLabel.frame.maxY + 15, width: 50, height: 50))
        highLowTemp.text = "High/Low: \(tempMax)\u{00B0}/\(tempMin)\u{00B0}"
        highLowTemp.font = UIFont.systemFont(ofSize: 17)
        highLowTemp.sizeToFit()
        highLowTemp.frame.origin.x = view.frame.width / 2 - highLowTemp.frame.width / 2
        highLowTemp.textColor = UIColor.white
        view.addSubview(highLowTemp)
        
        let humidity = Int((tempData["humidity"] as! Double) * 100)
        humidityLabel = UILabel(frame: CGRect(x: 0, y: highLowTemp.frame.maxY + 15, width: 50, height: 50))
        humidityLabel.text = "Humidity: \(humidity)%"
        humidityLabel.font = UIFont.systemFont(ofSize: 17)
        humidityLabel.sizeToFit()
        humidityLabel.frame.origin.x = view.frame.width / 2 - humidityLabel.frame.width / 2
        humidityLabel.textColor = UIColor.white
        view.addSubview(humidityLabel)
        
        let wind = tempData["windSpeed"] as! Double
        windSpeed = UILabel(frame: CGRect(x: 0, y: humidityLabel.frame.maxY + 15, width: 50, height: 50))
        windSpeed.text = "Wind Speed: \(wind) mph"
        windSpeed.font = UIFont.systemFont(ofSize: 17)
        windSpeed.sizeToFit()
        windSpeed.frame.origin.x = view.frame.width / 2 - windSpeed.frame.width / 2
        windSpeed.textColor = UIColor.white
        view.addSubview(windSpeed)
    }
    
    func displaySunGif() {
        let sunView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        sunView.animationImages = sunGif
        sunView.animationDuration = 1.2
        sunView.startAnimating()
        sunView.layer.zPosition = -5
        view.addSubview(sunView)
    }
    
    func displayRainGif() {
        let rainView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        rainView.animationImages = rainGif
        rainView.animationDuration = 1
        rainView.layer.zPosition = -5
        rainView.startAnimating()
        view.addSubview(rainView)
    }
    
    func displayNightGif() {
        let nightView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        nightView.animationImages = nightGif
        nightView.animationDuration = 1
        nightView.layer.zPosition = -5
        nightView.startAnimating()
        view.addSubview(nightView)
    }
    
    func displayPoweredBy() {
        let poweredBy = UIButton(frame: CGRect(x: 0, y: view.frame.height - 30, width: 50, height: 50))
        poweredBy.setTitle("Powered By Dark Sky", for: .normal)
        poweredBy.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        poweredBy.sizeToFit()
        poweredBy.frame.origin.x = view.frame.width / 2 - poweredBy.frame.width / 2
        poweredBy.tintColor = UIColor.white
        poweredBy.addTarget(self, action: #selector(link), for: .touchUpInside)
        view.addSubview(poweredBy)
    }
    
    func link() {
        UIApplication.shared.openURL(NSURL(string: "https://darksky.net/poweredby/")! as URL)
    }

}

