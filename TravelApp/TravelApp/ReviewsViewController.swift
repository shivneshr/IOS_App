//
//  ReviewsViewController.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/16/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ReviewsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var reviews_mode: [reviews_model] = []
    var order : Int = 0
    var type : Int = 0
    var review_type: Int = 0
    
    let dateFormatter = DateFormatter()
    
    
    func sort(){
        if(order == 0){
            if(type == 1){
                reviews_mode = reviews_mode.sorted(by: {$0.rating < $1.rating})
            }
            else if(type == 2){
                reviews_mode = reviews_mode.sorted(by: {$0.time < $1.time})
            }
        }else if(order == 1){
            if(type == 1){
                reviews_mode = reviews_mode.sorted(by: {$0.rating > $1.rating})
            }
            else if(type == 2){
                reviews_mode = reviews_mode.sorted(by: {$0.time > $1.time})
            }
        }
        self.reviewTable.reloadData()
    }
    
    @IBOutlet weak var reviewTable: UITableView!
    
    @IBAction func changeReview(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            review_type = 0
            reviews_mode = shared_place_model._shared_place_model.google_place_reviews
            sort()
            break
        case 1:
            review_type = 1
            reviews_mode = shared_place_model._shared_place_model.yelp_place_reviews
            sort()
            break
        default:
            break
        }
    }
    
    @IBAction func changeSortType(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            type = 0
            if(review_type == 0){
                reviews_mode = shared_place_model._shared_place_model.google_place_reviews
            }
            else{
                reviews_mode = shared_place_model._shared_place_model.yelp_place_reviews
            }
            self.reviewTable.reloadData()
        case 1:
            type = 1
            sort()
            break
        case 2:
            type = 2
            sort()
            break
        default:
            break
        }
    }
    
    @IBAction func changeSortOrder(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            order = 0
            sort()
            break
        case 1:
            order = 1
            sort()
            break
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reviews_mode = shared_place_model._shared_place_model.google_place_reviews
        reviewTable.delegate = self
        reviewTable.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        // #warning Incomplete implementation, return the number of rows
        return reviews_mode.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        cell.userImage.image = reviews_mode[indexPath.row].profile_photo
        cell.userRating.rating = Double(reviews_mode[indexPath.row].rating)!
        cell.userReview.text = reviews_mode[indexPath.row].text
        
        if(review_type == 0)
        {
            let date = Date(timeIntervalSince1970: Double(reviews_mode[indexPath.row].time)!)
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Specify your format that you want
            cell.userDate.text = dateFormatter.string(from: date)
        }else{
            cell.userDate.text = reviews_mode[indexPath.row].time
        }
        
        
        cell.userName.text = reviews_mode[indexPath.row].author_name
        
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        var numOfSections: Int = 0
        if(reviews_mode.count > 0)
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No reviews available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell: reviews_model = reviews_mode[indexPath.row]
        let urlAsString = cell.author_url
        let url = URL(string : urlAsString)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url!)
        }
    }

}
