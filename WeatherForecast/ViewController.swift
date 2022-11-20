//
//  ViewController.swift
//  WeatherForecast
//
//  Created by junni zhou on 11/19/22.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftSpinner


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var txtCity: UITextField!
    
    
    let locationManager = CLLocationManager()
    
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    var temps = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
    }
    
    
    
    @IBAction func getCurrentWeather(_ sender: Any) {
        
        let locationStr = "\(self.lat!),\(self.lon!)"
        
        var url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/weatherdata/forecast?locations="
        
        url += locationStr
        
        url +=  "&aggregateHours=24&unitGroup=us&shortColumnNames=false&contentType=json&key=AYQR6QM5KHFYVPH9M4EXXJUCC"
        
        AF.request(url).responseJSON { responseData in
            
            //print(responseData)
            
            if responseData.error != nil {
                
                print(responseData.error!)
                
                return
                
            }
            
            
            let weatherData = JSON(responseData.data as Any)
            let forecastValues =  weatherData["locations"][locationStr]["values"]
            
            print(forecastValues.count)
            
            self.temps = [String]()
            for forecast in forecastValues {
                
                let forecastJSON = JSON(forecast.1)
                let temp = forecastJSON["temp"].floatValue
                let condition = forecastJSON["conditions"].stringValue
                let str = "Temperature = \(temp)℉, \(condition)"
                self.temps.append(str)
                print(forecast)

            }
            self.tblView.reloadData()
        }
    }
    
    
    @IBAction func getWeatherForecast(_ sender: Any) {
        
        let cityName = txtCity.text!
        
        var url = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/weatherdata/forecast?locations="
        
        url += cityName +  "&aggregateHours=24&unitGroup=us&shortColumnNames=false&contentType=json&key=AYQR6QM5KHFYVPH9M4EXXJUCC"
        
        AF.request(url).responseJSON { responseData in
            
            //print(responseData)
            
            if responseData.error != nil {
                
                print(responseData.error!)
                
                return
                
            }
            
            
            let weatherData = JSON(responseData.data as Any)
            
            let forecastValues =  weatherData["locations"][self.txtCity.text!]["values"]
            
            print(forecastValues.count)
            
            self.temps = [String]()
            for forecast in forecastValues {
                
                let forecastJSON = JSON(forecast.1)
                let temp = forecastJSON["temp"].floatValue
                let condition = forecastJSON["conditions"].stringValue
                let str = "Temperature = \(temp)℉, \(condition)"
                self.temps.append(str)
                print(forecast)

            }
            self.tblView.reloadData()
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return temps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = temps[indexPath.row]
        return cell
    }
}
