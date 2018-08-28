//
//  CustomPicTableViewCell.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/21/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import UIKit

class CustomPicTableViewCell: UITableViewCell {

    @IBOutlet weak var placeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
