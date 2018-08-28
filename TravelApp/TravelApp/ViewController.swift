//
//  ViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/13/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import GooglePlaces
import EasyToast
import SwiftSpinner


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    // Outlets
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var location: UITextField!
    
    
    var categoryPicker = UIPickerView()
    
    var categoryData=["Default","Airport","Amusement Park","Aquarium","Art Gallery","Bakery","Bar","Beauty salon","Bowling Alley","Bus Station","Cafe","Campground","Car Rental","Casino","Lodging","Movie Theater","Museum","Night Club","Park","Parking","Restaurant","Shopping Mall","Stadium","Subway Station","Taxi Stand","Train Station","Transit Station","Travel Agency","Zoo"]
    
    var locationManager: CLLocationManager!
    var placeDetails: [PlaceDetail]?
    
    @IBAction func locationClick(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func Clear(_ sender: Any) {
        self.view.showToast("Hello There", position: .bottom, popTime: kToastNoPopTime, dismissOnTap: true)
        SwiftSpinner.show(duration: 4.0, title: "It's taking longer than expected")
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC : PlaceTableViewController = segue.destination as! PlaceTableViewController
        destVC.currentSet = placeDetails
     }
    
    
    @IBAction func Search(_ sender: Any) {
        
        let reqBody = requestBody(location: "34.0266,-118.2831",
                                  keyword:"default",
                                  type: "restaurant",
                                  radius:500)
        guard let reqData = try? JSONEncoder().encode(reqBody) else {
            return
        }
        
        let url = URL(string: "https://api-project-14176548612.appspot.com/places_new")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.uploadTask(with: request, from: reqData) { data, response, error in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                    print ("server error")
                    return
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                let placeData = try decoder.decode(ResponseObject.self, from: data)
                print(placeData.data.count)
                self.placeDetails = placeData.data
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "listPlaces", sender: self)
                }
            } catch let err {
                print("Err", err)
            }
        }
        task.resume()
        
    }
    
    // Picker View element description
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category.text = categoryData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryData[row]
    }

    
    // Events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Reading the favorites from the User Defaults
        let userdata = UserDefaults.standard.object(forKey: "SavedArray")
        if(userdata != nil)
        {
            do {
                let decoder = JSONDecoder()
                let user_data: defaultStore =  try decoder.decode(defaultStore.self, from: userdata as! Data)
                shared_place_model._shared_place_model.favorites = user_data.favorites
            }
            catch let err{
                print(err)
                shared_place_model._shared_place_model.favorites = [PlaceDetail]()
            }
        }
        else
        {
            shared_place_model._shared_place_model.favorites = [PlaceDetail]()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.navigationItem.title = "Places Search";
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        categoryPicker.backgroundColor = UIColor.white
        category.inputView = categoryPicker
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ViewController.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        category.inputAccessoryView = toolBar
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        shared_place_model._shared_place_model.startLocation = placeLocation(lat: Float(locValue.latitude), lng: Float(locValue.longitude))
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    @objc func doneClick() {
        category.resignFirstResponder()
    }
    @objc func cancelClick() {
        category.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// Google map Auto-fill definition
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        location.text = place.formattedAddress
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

