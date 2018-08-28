//
//  ReviewTableViewCell.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/21/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var userDate: UILabel!
    @IBOutlet weak var userReview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
