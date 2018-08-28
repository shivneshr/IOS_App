//
//  FormTestViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/24/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import GooglePlaces
import SwiftSpinner
import EasyToast

class FormTestViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var keyword: UITextField!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var category: UITextField!
    
    var placeDetails: [PlaceDetail]?
    var placeLoc: placeLocation?
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC : PlaceTableViewController = segue.destination as! PlaceTableViewController
        destVC.currentSet = placeDetails
    }
    
    
    @IBAction func search(_ sender: Any) {
        
        if(keyword.text?.isEmpty == false)
        {
            SwiftSpinner.show("Searching...")
            let locValue: placeLocation
            if(location.text == "Your Location" || (location.text?.isEmpty)!)
            {
                locValue = shared_place_model._shared_place_model.startLocation
            }
            else{
                locValue = placeLoc!
            }
            
            print("locations = \(locValue.lat) \(locValue.lng)")
            
            var radius: Int = 10*1609
            if(distance.text?.isEmpty == false)
            {
                radius = Int(distance.text!)!*1609
            }
            
            
            let reqBody = requestBody(location: "\(locValue.lat),\(locValue.lng)",
                                      keyword:keyword.text!,
                                      type: category.text!,
                                      radius:radius)
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
                        SwiftSpinner.hide()
                        self.performSegue(withIdentifier: "listplaces1", sender: self)
                    }
                } catch let err {
                    print("Err", err)
                }
            }
            task.resume()
        }
        else{
            self.view.showToast("Keyword cannot be empty", position: .bottom, popTime: 3, dismissOnTap: false)
        }
        
 
    }
    
    
    @IBAction func clear(_ sender: Any) {
        keyword.text = ""
        category.text = "Default"
        location.text = "Your Location"
        distance.text = ""
        shared_place_model._shared_place_model.customStartLocation = nil
    }
    
    
    
    var categoryPicker = UIPickerView()
    
    var categoryData=["Default","Airport","Amusement Park","Aquarium","Art Gallery","Bakery","Bar","Beauty salon","Bowling Alley","Bus Station","Cafe","Campground","Car Rental","Casino","Lodging","Movie Theater","Museum","Night Club","Park","Parking","Restaurant","Shopping Mall","Stadium","Subway Station","Taxi Stand","Train Station","Transit Station","Travel Agency","Zoo"]
    
    @IBAction func locationchange(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
extension FormTestViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        location.text = place.formattedAddress
        placeLoc = placeLocation(lat: Float(place.coordinate.latitude), lng: Float(place.coordinate.longitude))
        shared_place_model._shared_place_model.customStartLocation = placeLocation(lat: Float(place.coordinate.latitude), lng: Float(place.coordinate.longitude))
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
