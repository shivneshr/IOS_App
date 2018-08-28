//
//  FormTableViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/24/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit

class FormTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var FavTable: UITableView!
    var imageList = [UIImage]()
    let defaults = UserDefaults.standard
    var numOfSections: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FavTable.delegate = self
        FavTable.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete implementation, return the number of rows
        return shared_place_model._shared_place_model.favorites.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(shared_place_model._shared_place_model.favorites[indexPath.row].place_id)
        
        shared_place._shared_place_id.shared_id = shared_place_model._shared_place_model.favorites[indexPath.row].place_id
        shared_place_model._shared_place_model.current_place = shared_place_model._shared_place_model.favorites[indexPath.row]
        shared_place_model._shared_place_model.place_location = placeLocation(lat: Float(shared_place_model._shared_place_model.favorites[indexPath.row].latitude), lng: Float(shared_place_model._shared_place_model.favorites[indexPath.row].longitude))
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath) as! FavTableViewCell
        
        if !imageList.indices.contains(indexPath.row){
            let url = URL(string: (shared_place_model._shared_place_model.favorites[indexPath.row].Category))
            let data = try? Data(contentsOf: url!)
            if let imageData = data {
                imageList.append(UIImage(data: imageData)!)
            }
        }
        
        cell.category_image.image = imageList[indexPath.row]
        cell.title.text = shared_place_model._shared_place_model.favorites[indexPath.row].Name
        cell.subtitle.text = shared_place_model._shared_place_model.favorites[indexPath.row].Address
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == .delete){
            shared_place_model._shared_place_model.favorites.remove(at: indexPath.row)
            
            let jsonObject = defaultStore(favorites: shared_place_model._shared_place_model.favorites)
            guard let favData = try? JSONEncoder().encode(jsonObject) else {
                return
            }
            defaults.set(favData, forKey: "SavedArray")
            //FavTable.beginUpdates()
            FavTable.deleteRows(at: [indexPath], with: .automatic)
            //FavTable.endUpdates()
            FavTable.reloadData()
        }
    }
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if(shared_place_model._shared_place_model.favorites.count > 0)
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Favorites"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.FavTable.reloadData()
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
