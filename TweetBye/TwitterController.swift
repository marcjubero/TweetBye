//
//  TwitterController.swift
//  TweetBye
//
//  Created by Marc Juberó on 10/02/16.
//
//

import Foundation
import TwitterKit

class TwitterController {
    
    var twitterClient:AnyObject?
    
    init() {
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            self.twitterClient = TWTRAPIClient(userID: userID)
        }
    }
    
    
}
