//
//  UnfollowerProfileViewController.swift
//  TweetBye
//
//  Created by Marc Juberó on 10/02/16.
//
//

import UIKit
import Kingfisher
import TwitterKit
import SwiftyJSON

class UnfollowerProfileViewController: UIViewController {
    
    var user:UserProfile?

    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let URL = NSURL(string: user!.bannerImgUrl) {
            bannerImage.kf_setImageWithURL(URL, placeholderImage: UIImage(named: "placeholder")!)
        }
        
        if let URL = NSURL(string: user!.profileImgUrl) {
            profileImage.kf_setImageWithURL(URL, placeholderImage: UIImage(named: "placeholder")!)
            
            self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
            self.profileImage.clipsToBounds = true;
            
            self.profileImage.layer.borderWidth = 3.0
            self.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        userName.text = user!.name
        screenName.text = "@\(user!.screenName)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tweetGoodByeToUser(sender: UIButton) {
        print("tweet goodbye to @\(user!.screenName)")
        self.sendTweet(false)
    }
    
    @IBAction func tweetNastyGoodByeToUser(sender: UIButton) {
        print("nasty goodbye tweet to @\(user!.screenName)")
        self.sendTweet(true)
    }
    
    @IBAction func blockUser(sender: UIButton) {
        self.blockOrUnfollowUser(true)
    }
    
    @IBAction func unfollowUser(sender: UIButton) {
        self.blockOrUnfollowUser(false)
    }
    
    func sendTweet(nasty:Bool) {
        let composer = TWTRComposer()
        
        let text = (nasty) ? "hey you ulgy bastard! Why the fuck did u unfollowed me? " : "why did u unfollowed me!? :'("
        composer.setText("@\(user!.screenName) \(text)")
        
        composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
        }
    }
    
    func blockOrUnfollowUser(block:Bool) {
        /*
        let url = (block) ? "https://api.twitter.com/1.1/blocks/create.json" : "https://api.twitter.com/1.1/friendships/destroy.json"
        
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            let params = ["user_id": user!.id]
            var clientError : NSError?
            
            let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod("POST", URL: url, parameters: params, error: &clientError)
             
            
            client.sendTwitterRequest(request) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    print("Unfollowed")
                } else {
                    print("error -> \(error)")
                }
            }
        }*/
        let text = (block) ? "blocking @\(user!.screenName)" : "unfollowing @\(user!.screenName)"
        print(text)
    }
}
