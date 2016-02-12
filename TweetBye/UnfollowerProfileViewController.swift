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
            
            // add blur effect
            //let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Light)
            //let blurView = UIVisualEffectView(effect: darkBlur)
            //blurView.frame = bannerImage.bounds
            //bannerImage.addSubview(blurView)
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
        print("block @\(user!.screenName)")
    }
    
    @IBAction func unfollowUser(sender: UIButton) {
        print("unfollow @\(user!.screenName)")
    }
    
    func sendTweet(nasty:Bool) {
        let composer = TWTRComposer()
        
        if nasty {
            composer.setText("@\(user!.screenName) hey you ulgy bastard! Why the fuck id u unfollowed me? ")
        } else {
            composer.setText("@\(user!.screenName) why did u unfollowed me!? :'(")
        }
        
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
        var url = ""
        
        if block {
            
        } else {
            url = "https://api.twitter.com/1.1/friendships/destroy.json?user_id=" + String(user!.id)
        }
    
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let client = TWTRAPIClient(userID: userID)
            let request = NSURLRequest(URL: NSURL(string: "https://api.twitter.com/1.1/followers/ids.json")!)
            
            client.sendTwitterRequest(request) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let json = JSON(data: data!)
                    if let followerIdsArray = json["ids"].array {
                        print("followers count -> \(followerIdsArray.count)")
                        
                        for var index = 0; index < followerIdsArray.count; index++ {
                            let identifier = followerIdsArray[index]
                            self.saveOrUpdateFollowerId(String(identifier), epoch: String(epoch))
                        }
                        
                        self.getUnfollowers(String(epoch))
                        
                    } else {
                        print("error fetching followers ids")
                    }
                    
                } else {
                    print("error -> \(error)")
                }
            }
        }
    }
}
