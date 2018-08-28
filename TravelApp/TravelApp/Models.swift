//
//  Models.swift
//  TravelApp
//
//  Created by Shivnesh Rajan on 4/15/18.
//  Copyright © 2018 Shivnesh Rajan. All rights reserved.
//

import Foundation
import UIKit

struct PlaceDetail: Codable {
    let Category: String
    let Name: String
    let Address: String
    let place_id: String
    let latitude: Double
    let longitude: Double
}

struct ResponseObject:Decodable{
    let statusCode: Int
    let data: [PlaceDetail]
    let error: String
}

struct requestBody: Codable {
    let location: String
    let keyword: String
    let type: String
    let radius: Int
}

struct yelpRequestBody: Codable{
    var address1: String!
    var name: String!
    var city: String!
    var state: String!
    var country: String!
}


struct reviews_model {
    let author_name: String?
    let author_url: String
    let profile_photo_url: String?
    let profile_photo: UIImage?
    let rating: String
    let text: String?
    let time: String
}


struct place_model {
    let Address: String?
    let Name: String?
    let PhoneNumber: String?
    let PriceLevel: Int
    let Rating: Float
    let Website: String?
    let GooglePage: String?
}


struct placeLocation{
    let lat: Float
    let lng: Float
}

class shared_place{
    
    private init(){}
    
    static let _shared_place_id = shared_place()
    
    var shared_id: String!
}

struct defaultStore: Codable{
    var favorites: [PlaceDetail]
}

class shared_place_model {
    
    // Can't init is singleton
    private init() {}
    
    // MARK: Shared Instance
    
    static let _shared_place_model = shared_place_model()
    
    // MARK: Local Variable
    
    var place_detail: place_model!
    var current_place: PlaceDetail!
    var google_place_reviews: [reviews_model]!
    var yelp_place_reviews: [reviews_model]!
    var place_location: placeLocation!
    var place_photos: [UIImage]!
    var place_id: String!
    var startLocation: placeLocation!
    var customStartLocation: placeLocation?
    var favorites: [PlaceDetail]!
}
