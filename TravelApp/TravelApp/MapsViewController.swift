//
//  MapsViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/16/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON


class MapsViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var map_view: GMSMapView!
    @IBOutlet weak var from: UITextField!
    
    @IBOutlet weak var segmentTravel: UISegmentedControl!
    
    @IBAction func modeOfTravel(_ sender: UISegmentedControl) {
        let travelMode = sender.titleForSegment(at: sender.selectedSegmentIndex)
        self.drawPath(startLocation: locationStart, endLocation: locationEnd, mode: travelMode!)
    }
    
    var locationManager = CLLocationManager()
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    
    @IBAction func from_click(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationEnd = CLLocation(latitude: CLLocationDegrees(shared_place_model._shared_place_model.place_location.lat), longitude: CLLocationDegrees(shared_place_model._shared_place_model.place_location.lng))
        
        if(shared_place_model._shared_place_model.customStartLocation != nil){
            locationStart = CLLocation(latitude: CLLocationDegrees((shared_place_model._shared_place_model.customStartLocation?.lat)!), longitude: CLLocationDegrees((shared_place_model._shared_place_model.customStartLocation?.lng)!))
        }else{
            locationStart = CLLocation(latitude: CLLocationDegrees(shared_place_model._shared_place_model.startLocation.lat), longitude: CLLocationDegrees(shared_place_model._shared_place_model.startLocation.lng))
        }
        
        
        //let camera = GMSCameraPosition.camera(withLatitude: 34.0266, longitude: -118.2831, zoom: 5.0)
        let camera = GMSCameraPosition.camera(withLatitude: locationEnd.coordinate.latitude, longitude: locationEnd.coordinate.longitude, zoom: 15)
        map_view.camera = camera
        map_view.settings.zoomGestures = true
        // Do any additional setup after loading the view.
        
        //locationEnd = CLLocation(latitude: 34.0266, longitude: -118.2831)
        createMarker(titleMarker: "Target Location", latitude: locationEnd.coordinate.latitude, longitude: locationEnd.coordinate.longitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createMarker(titleMarker: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.map = map_view
    }
    
    
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation, mode: String)
    {
        self.map_view.clear()
        
        createMarker(titleMarker: "Start Location", latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        createMarker(titleMarker: "End Location", latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=\(mode.lowercased())"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = try? JSON(data: response.data!)
            let routes = json!["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.map_view
            }
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


// Google map Auto-fill definition
extension MapsViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 16.0)
        locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        createMarker(titleMarker: "Location Start", latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        self.map_view.camera = camera
        from.text = place.formattedAddress
        
        segmentTravel.selectedSegmentIndex=0;
        segmentTravel.selectedSegmentIndex = UISegmentedControlNoSegment;
        
        self.drawPath(startLocation: locationStart, endLocation: locationEnd, mode: "driving")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
