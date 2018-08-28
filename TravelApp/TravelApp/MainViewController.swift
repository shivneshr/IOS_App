//
//  MainViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/24/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class MainViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    @IBOutlet weak var formview: UIView!
    @IBOutlet weak var tableview: UIView!
    
    @IBAction func viewChanger(_ sender: UISegmentedControl) {
        
        if(sender.selectedSegmentIndex == 0){
            formview.alpha = 0.0
            tableview.alpha = 1.0
            
        }else{
            formview.alpha = 1.0
            tableview.alpha = 0.0
            let child : FormTableViewController = self.childViewControllers[0] as! FormTableViewController
            child.FavTable.reloadData()
        }
    }
    
    private func prepareNavigationBarItems(){
        self.navigationItem.title = "Places Search";
        //let shareButton = UIButton(type: .system)
        //shareButton.setImage(#imageLiteral(resourceName: "forward-arrow"), for: .normal)
        //self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: shareButton)]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBarItems()
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
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        shared_place_model._shared_place_model.startLocation = placeLocation(lat: Float(locValue.latitude), lng: Float(locValue.longitude))
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Places Search"
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
