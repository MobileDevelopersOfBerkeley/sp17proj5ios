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
    var raintime = -1
    var moonPhase = -1.0
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
                            self.raintime = point.1["time"].number as! Int
                            break
                        }
                    }
                }
                if daily["data"][0]["moonPhase"] != JSON.null {
                    self.moonPhase = daily["data"][0]["moonPhase"] as! Double
                }
                print(self.temp)
                print(self.summary)
                print(self.raintime)
                print(self.moonPhase)
                
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



