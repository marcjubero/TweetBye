//
//  UserProfile.swift
//  TweetBye
//
//  Created by Marc Juberó on 09/02/16.
//
//

import Foundation
import SwiftyJSON

class UserProfile {
    let id:Int
    let name:String
    let screenName:String
    let description:String
    let bannerImgUrl:String
    let profileImgUrl:String
    
    init(id:Int, name:String, screenName:String, description:String, bannerImgUrl:String, profileImgUrl:String) {
        self.id = id
        self.name = name
        self.screenName = screenName
        self.description = description
        self.bannerImgUrl = bannerImgUrl
        self.profileImgUrl = profileImgUrl
    }
    
    init(twitterNetData:NSData?) {
        let json = JSON(data: twitterNetData!)
        
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.screenName = json["screen_name"].stringValue
        self.description = json["description"].stringValue
        self.bannerImgUrl = json["profile_banner_url"].stringValue
        self.profileImgUrl = json["profile_image_url"].stringValue
    }
    
    func toString() -> String {
        return "id -> \(self.id), name -> \(self.name), screenName -> \(self.screenName), description -> \(self.description), bannerUrl -> \(self.bannerImgUrl), profileUrl -> \(self.profileImgUrl)"
    }
}
