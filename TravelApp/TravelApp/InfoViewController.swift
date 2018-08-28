//
//  InfoViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/16/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import GooglePlaces
import Alamofire
import SwiftyJSON
import SwiftSpinner
import Cosmos

class InfoViewController: UIViewController {

    @IBOutlet weak var Address: UITextView!
    @IBOutlet weak var phone_number: UITextView!
    @IBOutlet weak var price_level: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var website: UITextView!
    @IBOutlet weak var google_page: UITextView!
    
    var arrayPlaceId = [String]()
    let defaults = UserDefaults.standard
    
    @IBAction func addToFav(_ sender: Any) {
        print("Adding to fav")
    }
    
    @IBAction func shareToTwitter(_ sender: Any) {
        print("Sharing to Twitter")
    }
    
    func populate_UI() {
        if (shared_place_model._shared_place_model.place_detail?.Address) != nil{
            self.Address.text = shared_place_model._shared_place_model.place_detail?.Address
        }
        
        if (shared_place_model._shared_place_model.place_detail?.GooglePage) != nil{
            self.google_page.text = shared_place_model._shared_place_model.place_detail?.GooglePage
        }
        
        if (shared_place_model._shared_place_model.place_detail?.PhoneNumber) != nil{
            self.phone_number.text = shared_place_model._shared_place_model.place_detail?.PhoneNumber
        }
        
        if (shared_place_model._shared_place_model.place_detail?.Rating) != nil {
            self.rating.rating = Double((shared_place_model._shared_place_model.place_detail?.Rating)!)
        }
        
        if (shared_place_model._shared_place_model.place_detail?.Website) != nil{
            self.website.text = shared_place_model._shared_place_model.place_detail?.Website
        }
        
        if (shared_place_model._shared_place_model.place_detail?.PriceLevel) != nil && (shared_place_model._shared_place_model.place_detail?.PriceLevel) != -1 {
            self.price_level.text = String(repeating: "$", count: (shared_place_model._shared_place_model.place_detail?.PriceLevel)!)
        }
    }
    
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                for pics in (photos?.results)!{
                    self.loadImageForMetadata(photoMetadata: pics)
                }
                // Populates the InfoTabContoller
                self.populate_UI()
                SwiftSpinner.hide()
            }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                shared_place_model._shared_place_model.place_photos.append(photo!)
            }
        })
    }
    
    
    @objc func likeAction(sender: UIButton){
        arrayPlaceId = shared_place_model._shared_place_model.favorites.map {$0.place_id}
        
        let likebutton = UIButton(type: .system)
        likebutton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        likebutton.addTarget(self, action: #selector(likeAction(sender:)), for: .touchUpInside)
        
        if(arrayPlaceId.contains(shared_place_model._shared_place_model.current_place.place_id)){
            // remove from fav
            for (index,fav) in shared_place_model._shared_place_model.favorites.enumerated(){
                if(shared_place_model._shared_place_model.current_place.place_id == fav.place_id){
                    shared_place_model._shared_place_model.favorites.remove(at: index)
                    break
                }
            }
            likebutton.setImage(#imageLiteral(resourceName: "favorite-empty"), for: .normal)
            //shared_place_model._shared_place_model.favorites.remove(at: sender.tag)
            self.view.showToast("\(shared_place_model._shared_place_model.current_place.Name) removed from favourites", position: .bottom, popTime: 3, dismissOnTap: true)
            
            
        }else{
            // add to fav
            shared_place_model._shared_place_model.favorites.append(shared_place_model._shared_place_model.current_place)
            likebutton.setImage(#imageLiteral(resourceName: "favorite-filled"), for: .normal)
            self.view.showToast("\(shared_place_model._shared_place_model.current_place.Name) added to favourites", position: .bottom, popTime: 3, dismissOnTap: true)
        }
        
        self.tabBarController?.navigationItem.rightBarButtonItems![0] = UIBarButtonItem(customView: likebutton)
        
        let jsonObject = defaultStore(favorites: shared_place_model._shared_place_model.favorites)
        guard let favData = try? JSONEncoder().encode(jsonObject) else {
            return
        }
        defaults.set(favData, forKey: "SavedArray")
        print("I was clicked to like")
    }
    
    @objc func shareAction(sender: UIButton){
        let urlAsString: NSString = "https://twitter.com/intent/tweet?text=Check out \(shared_place_model._shared_place_model.place_detail.Name!) located at \(shared_place_model._shared_place_model.place_detail.Address!) Website: \(shared_place_model._shared_place_model.place_detail.Website!)" as NSString;
        
        let urlStr : NSString = urlAsString.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(searchURL as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(searchURL as URL)
        }
    }
    
    func prepareNavigationBar(){
        
        arrayPlaceId = shared_place_model._shared_place_model.favorites.map {$0.place_id}
        
        let sharebutton = UIButton(type: .system)
        
        sharebutton.setImage(#imageLiteral(resourceName: "forward-arrow"), for: .normal)
        sharebutton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        sharebutton.addTarget(self, action: #selector(shareAction(sender:)), for: .touchUpInside)
        
        let likebutton = UIButton(type: .system)
        
        
        if(arrayPlaceId.contains(shared_place_model._shared_place_model.current_place.place_id)){
            likebutton.setImage(#imageLiteral(resourceName: "favorite-filled"), for: .normal)
        }
        else{
            likebutton.setImage(#imageLiteral(resourceName: "favorite-empty"), for: .normal)
        }
        
        likebutton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        likebutton.addTarget(self, action: #selector(likeAction(sender:)), for: .touchUpInside)
        
        self.tabBarController?.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: likebutton),UIBarButtonItem(customView: sharebutton)]
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Prepare navigation bar
        prepareNavigationBar()
        // Prepare the display data for Tab Views
        prepareTabViewsData()
    }
    
    private func prepareTabViewsData(){
        let placeID = shared_place._shared_place_id.shared_id!
        let placesClient = GMSPlacesClient()
        var reviews_mode: [reviews_model] = []
        var yelp_review_mode: [reviews_model] = []
        var googlePage: String = ""
        
        if (placeID != shared_place_model._shared_place_model.place_id)
        {
            // Entering here means a new place id is info needs to be prepared
            SwiftSpinner.show("Loading next page...")
            
            // Reset the existing place id details
            shared_place_model._shared_place_model.place_id = placeID
            shared_place_model._shared_place_model.place_photos = []
            shared_place_model._shared_place_model.yelp_place_reviews = []
            shared_place_model._shared_place_model.google_place_reviews = []
            
            // Place URL to obtain the reviews and Google Page details
            let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(String(describing: placeID))&key=AIzaSyBsHy8OvOaWhOwvPo98b3jOrxFCN4kr5Us"
            
            Alamofire.request(url).responseJSON { (response) -> Void in
                
                // Parsing JSON response and storing it in an JSON object
                let JsonResponse = JSON(response.result.value!)
                
                // Retrieving the reviews (Missing in IOS Google API)
                let reviews = JsonResponse["result"]["reviews"].arrayValue
                
                // Retrieving the Google Page (Missing in IOS Google API)
                googlePage = JsonResponse["result"]["url"].rawString()!
                
                // Store reviews in reviewList
                for review in reviews
                {
                    var profile_photo: UIImage? = nil
                    
                    let url = URL(string: review["profile_photo_url"].stringValue)
                    if url != nil{
                        let data = try? Data(contentsOf: url!)
                        if let imageData = data {
                            profile_photo = UIImage(data: imageData)!
                        }
                    }
                   
                    reviews_mode.append(reviews_model(author_name: review["author_name"].stringValue, author_url: review["author_url"].stringValue, profile_photo_url: review["profile_photo_url"].stringValue, profile_photo: profile_photo!, rating: review["rating"].stringValue, text: review["text"].stringValue, time: review["time"].stringValue))
                }
                
                // Assigning shared google reviews
                shared_place_model._shared_place_model.google_place_reviews = reviews_mode
                
                
                // Getting the Address component as the Split up is missing in the IOS Google API
                let address_components = JsonResponse["result"]["address_components"].arrayValue
                let formatted_address = JsonResponse["result"]["formatted_address"].stringValue
                
                
                var yelpParameter = yelpRequestBody()
                
                for address in address_components{
                    if(address["types"][0] == "administrative_area_level_2"){
                        print(address["short_name"])
                        yelpParameter.city = address["short_name"].stringValue
                    }
                    else if(address["types"][0] == "administrative_area_level_1"){
                        yelpParameter.state = address["short_name"].stringValue
                    }
                    else if(address["types"][0] == "country"){
                        yelpParameter.country = address["short_name"].stringValue
                    }
                }
                
                let address : [String] = formatted_address.components(separatedBy: ",")
                yelpParameter.address1 = address[0]
                yelpParameter.name = JsonResponse["result"]["name"].stringValue
                
                
                let params = [
                    "address1": yelpParameter.address1,
                    "name": yelpParameter.name,
                    "city": yelpParameter.city,
                    "state": yelpParameter.state,
                    "country": yelpParameter.country
                ]
                
                Alamofire.request("https://api-project-14176548612.appspot.com/yelpreviews", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON{ response in
                    switch response.result {
                    case .success:
                        let yelp_reviews = JSON(response.result.value!).arrayValue
                        
                        for review in yelp_reviews
                        {
                            var profile_photo: UIImage? = nil
                            
                            let url = URL(string: review["user"]["image_url"].stringValue)
                            
                            if(url != nil)
                            {
                                let data = try? Data(contentsOf: url!)
                                if let imageData = data {
                                    profile_photo = UIImage(data: imageData)!
                                }
                            }

                            
                            yelp_review_mode.append(reviews_model(author_name: review["user"]["name"].stringValue, author_url: review["url"].stringValue, profile_photo_url: review["user"]["image_url"].stringValue, profile_photo: profile_photo, rating: review["rating"].stringValue, text: review["text"].stringValue, time: review["time_created"].stringValue))
                        }
                        
                        shared_place_model._shared_place_model.yelp_place_reviews = yelp_review_mode
                        
                        break
                    case .failure(let error):
                        print(error)
                    }
                }
                
                placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    
                    self.tabBarController?.navigationItem.title = place?.name
                    //self.navigationItem.title = place?.name;
                    // Assigning shared Place Detail
                    
                    if(place != nil){
                        shared_place_model._shared_place_model.place_detail = place_model(Address: (place?.formattedAddress), Name: (place?.name), PhoneNumber: (place?.phoneNumber), PriceLevel: (place?.priceLevel.rawValue)!, Rating: (place?.rating)!, Website: (place?.website?.absoluteString), GooglePage: googlePage)
                    
                        shared_place_model._shared_place_model.place_photos = []
                        self.loadFirstPhotoForPlace(placeID: placeID)
                    }
                    
                })
            }
            
        }else{
            self.populate_UI()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
