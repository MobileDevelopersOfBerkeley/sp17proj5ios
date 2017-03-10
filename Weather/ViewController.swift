/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var temp = -273
    var summary = ""
    var rainTimeUnix = -1
    var rainMessage = ""
    var moonPhase = -1.0
    var tempLabel: UILabel!
    var summaryLabel: UILabel!
    var rainMessageLabel: UILabel!
    var rainTime = ""
    var color = backGround.hot
    var moon: UIImageView!
    
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
        
        
        
        moon = UIImageView(frame: CGRect(x: 10, y: rainMessageLabel.frame.maxY, width: view.frame.width - 20, height: view.frame.width - 20))
        moon.image = whichMoon()
        view.addSubview(moon)
        
        
    }
    
    func whichMoon()->UIImage {
        for i in 0..<14 {
            if Double(i) * 0.0714 >= moonPhase {
                let index = i + 1
                let file = "moon" + String(index)
                return UIImage(named: file)!
            }
            
        }
        return UIImage()
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
