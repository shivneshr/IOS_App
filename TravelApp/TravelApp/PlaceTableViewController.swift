//
//  PlaceTableViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/15/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import SwiftyJSON
import EasyToast
import SwiftSpinner

class PlaceTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var PlaceTableView: UITableView!
    
    
    @IBAction func PrevClick(_ sender: Any) {
        let start: Int = (index - 1) * 20
        index = index - 1
        let end: Int = start + 20
        
        let sliceTags: Slice<[PlaceDetail]> = currentSet![start..<end]
        currentShow = Array(sliceTags)
        
        if(index == 0){
            Prev.isEnabled = false
            Next.isEnabled = true
        }else{
            Prev.isEnabled = true
            Next.isEnabled = true
        }
        SwiftSpinner.show(duration: 1.0, title: "Loading Previous Page")
        self.PlaceTableView.reloadData()
    }
    
    
    @IBAction func NextClick(_ sender: Any) {
        let start: Int = index * 20
        let end: Int = start + 20
        
        if(end>(currentSet?.count)!){
            let sliceTags: Slice<[PlaceDetail]> = currentSet![start..<(currentSet?.count)!]
            currentShow = Array(sliceTags)
            Next.isEnabled = false
        }else{
            let sliceTags: Slice<[PlaceDetail]> = currentSet![start..<end]
            index = index + 1
            currentShow = Array(sliceTags)
            if(index == 3){
                index = index - 1
                Next.isEnabled = false
            }else{
                Next.isEnabled = true
            }
            
        }
        Prev.isEnabled = true
        SwiftSpinner.show(duration: 1.0, title: "Loading Next Page")
        self.PlaceTableView.reloadData()
    }
    
    @IBOutlet weak var Next: UIButton!
    @IBOutlet weak var Prev: UIButton!
    
    var currentSet: [PlaceDetail]?
    var currentShow: [PlaceDetail]?
    var index: Int = 0
    
    
    var imageList = [UIImage]()
    var arrayPlaceId = [String]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search Results";
        self.navigationItem.backBarButtonItem?.title = ""
        
        PlaceTableView.delegate = self
        PlaceTableView.dataSource = self
        arrayPlaceId = shared_place_model._shared_place_model.favorites.map {$0.place_id}
        
        if((currentSet?.count)!>20)
        {
            let sliceTags: Slice<[PlaceDetail]> = currentSet![0..<20]
            index = 1
            currentShow = Array(sliceTags)
            Prev.isEnabled = false
            Next.isEnabled = true
        }
        else
        {
            currentShow = currentSet
            Prev.isEnabled = false
            Next.isEnabled = false
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        var numOfSections: Int = 0
        
        if((currentSet?.count)! > 0)
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentShow!.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(currentShow![indexPath.row].place_id)

        
        shared_place._shared_place_id.shared_id = currentShow![indexPath.row].place_id
        shared_place_model._shared_place_model.current_place = currentShow![indexPath.row]
        shared_place_model._shared_place_model.place_location = placeLocation(lat: Float(currentSet![indexPath.row].latitude), lng: Float(currentSet![indexPath.row].longitude))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        cell.Name.text = currentShow?[indexPath.row].Name
        cell.Address.text = currentShow?[indexPath.row].Address
        
        if !imageList.indices.contains(indexPath.row){
            let url = URL(string: (currentShow?[indexPath.row].Category)!)
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                imageList.append(UIImage(data: imageData)!)
            }
        }
        
        
        cell.Category.image = imageList[indexPath.row]
        cell.fav_button.tag = indexPath.row
        
        
        if(arrayPlaceId.contains((currentShow?[indexPath.row].place_id)!))
        {
            cell.fav_button.isSelected = true
        }else{
            cell.fav_button.isSelected = false
        }
        
        cell.fav_button.addTarget(self, action: #selector(favAction(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func favAction(sender:UIButton){
        print(sender.tag)
        if(sender.isSelected){
            sender.isSelected = false
            
            for (index,fav) in shared_place_model._shared_place_model.favorites.enumerated(){
                if(currentShow?[sender.tag].place_id == fav.place_id){
                    shared_place_model._shared_place_model.favorites.remove(at: index)
                    break
                }
            }
            //shared_place_model._shared_place_model.favorites.remove(at: sender.tag)
            self.view.showToast("\(currentShow![sender.tag].Name) removed from favourites", position: .bottom, popTime: 3, dismissOnTap: true)
        }else{
            sender.isSelected = true
            shared_place_model._shared_place_model.favorites.append((currentShow?[sender.tag])!)
            self.view.showToast("\(currentShow![sender.tag].Name) added to favourites", position: .bottom, popTime: 3, dismissOnTap: true)
        }
        
        arrayPlaceId = shared_place_model._shared_place_model.favorites.map {$0.place_id}
        // Converting to JSON String to store it in User Defaults
        let jsonObject = defaultStore(favorites: shared_place_model._shared_place_model.favorites)
        guard let favData = try? JSONEncoder().encode(jsonObject) else {
            return
        }
        defaults.set(favData, forKey: "SavedArray")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Search Results";
        arrayPlaceId = shared_place_model._shared_place_model.favorites.map {$0.place_id}
        self.PlaceTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationItem.title = "";
    }

}
