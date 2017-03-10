//
//  MoonViewController.swift
//  Weather
//
//  Created by Zach Govani on 3/10/17.
//  Copyright © 2017 Zach Govani. All rights reserved.
//

import UIKit
import Foundation

class MoonViewController: UIViewController {
    
    var moon: UIImageView
    
    // Use this for different backgrounds based on current weather
    enum backGround {
        case hot
        case cold
        case rainy
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData()
    }
    
    func setUpView() {
        setupGradient()
        
        tempLabel = UILabel(frame: CGRect(x: 10, y: 30, width: view.frame.width / 2, height: view.frame.height / 10))
        tempLabel.text = String(temp) + "°F"
        tempLabel.textColor = UIColor.black
        tempLabel.font = UIFont.systemFont(ofSize: 24, weight: 2)
        view.addSubview(tempLabel)
        
        
        summaryLabel = UILabel(frame: CGRect(x: 10, y: tempLabel.frame.maxY, width: view.frame.width - 20, height: view.frame.height / 10))
        summaryLabel.text = summary
        summaryLabel.textColor = UIColor.black
        summaryLabel.font = UIFont.systemFont(ofSize: 24, weight: 2)
        view.addSubview(summaryLabel)
        
        
        rainMessageLabel = UILabel(frame: CGRect(x: 10, y: summaryLabel.frame.maxY, width: view.frame.width - 20, height: view.frame.height / 10))
        rainMessageLabel.text = rainMessage
        rainMessageLabel.textColor = UIColor.black
        rainMessageLabel.font = UIFont.systemFont(ofSize: 24, weight: 2)
        view.addSubview(rainMessageLabel)
        
        
    }
    
    func setupGradient() {
        if color == backGround.hot {
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.red.cgColor, UIColor.white.cgColor]
            gradient.startPoint = CGPoint(x: 1, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
            view.layer.insertSublayer(gradient, at: 0)
        }
        if color == backGround.cold {
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.blue.cgColor, UIColor.white.cgColor]
            gradient.startPoint = CGPoint(x: 1, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
            view.layer.insertSublayer(gradient, at: 0)
        }
        if color == backGround.rainy {
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.darkGray.cgColor, UIColor.blue.cgColor]
            gradient.startPoint = CGPoint(x: 1, y: 1)
            gradient.endPoint = CGPoint(x: 0, y: 0)
            view.layer.insertSublayer(gradient, at: 0)
        }
        
    }
    
    func getWeatherData() {
        let locationManager = CLLocationManager()
        locationManager.delegate = ViewController()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        let URL: String = "https://api.darksky.net/forecast/230683c09185773ce2db5af129c9982e/" + "\(locationManager.location!.coordinate.latitude)" + "," + "\(locationManager.location!.coordinate.longitude)"
        
        Alamofire.request(URL).responseJSON{ response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                let minute = json["minutely"]
                let current = json["currently"]
                let daily = json["daily"]
                self.temp = current["temperature"].number as! Int
                print(current["temperature"].type)
                if current["temperature"] != JSON.null {
                    self.temp = current["temperature"].number as! Int
                }
                if minute["summary"] != JSON.null {
                    self.summary = minute["summary"].string!
                }
                let minutes = minute["data"]
                if minutes != JSON.null {
                    for point in minutes {
                        if point.1["precipProbability"] > 0 {
                            self.color = backGround.rainy
                            self.rainTimeUnix = point.1["time"].number as! Int
                            break
                        }
                        self.rainTimeUnix = point.1["time"].number as! Int
                    }
                }
                if daily["data"][0]["moonPhase"] != JSON.null {
                    self.moonPhase = daily["data"][0]["moonPhase"].number as! Double
                }
                self.rainTime = NSDate(timeIntervalSince1970: TimeInterval(self.rainTimeUnix)).description
                
                let start = self.rainTime.index(self.rainTime.startIndex, offsetBy: 11)
                let end = self.rainTime.index(self.rainTime.startIndex, offsetBy: 16)
                let range = start..<end
                
                self.rainTime = self.rainTime.substring(with: range)
                
                if self.rainTimeUnix == -1 {
                    self.rainMessage = "No rain in the next hour."
                }
                else {
                    self.rainMessage = "Rain at " + self.rainTime
                }
                if self.temp < 70 && self.color != backGround.rainy {
                    self.color = backGround.cold
                }
                
                print(self.temp)
                print(self.summary)
                print(self.rainTimeUnix)
                print(self.moonPhase)
                
                DispatchQueue.main.async {
                    self.setUpView()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //1
        if locations.count > 0 {
            let location = locations.last!
            
            if location.horizontalAccuracy < 100 {
                print("we made it")
                //3
                manager.stopUpdatingLocation()
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        print(error.debugDescription)
    }
}
