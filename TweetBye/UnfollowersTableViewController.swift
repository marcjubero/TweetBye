//
//  UnfollowersTableViewController.swift
//  TweetBye
//
//  Created by Marc Juberó on 08/02/16.
//
//

import UIKit
import TwitterKit
import SwiftyJSON
import CoreData
import Kingfisher

class UnfollowersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var unfollowerListView: UITableView!

    var selectedIndexPath:NSIndexPath!
    var unfollowers = [UserProfile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let epoch = NSDate().timeIntervalSince1970 * 1000
        
        fetchFollowersIds(String(epoch))
        
        let savedDataCount = self.countFetchFollowersFromCoreData()
        print("#saved data -> \(savedDataCount)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return unfollowers.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("unfollowerCell", forIndexPath: indexPath) as? UnfollowerTableViewCell {
            
            cell.userName.text = "\(unfollowers[indexPath.row].name) (@\(unfollowers[indexPath.row].screenName))"
            
            if let URL = NSURL(string: unfollowers[indexPath.row].profileImgUrl) {
                cell.profileImg.kf_setImageWithURL(URL, placeholderImage: UIImage(named: "placeholder")!)
            }
            
            return cell
        
        }
        
        // return empty cell
        return UITableViewCell()

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        performSegueWithIdentifier("showUnfollowerProfile", sender: self)
        
    }
    
    func fetchFollowersIds(epoch:String) {
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
    
    func saveOrUpdateFollowerId(identifier:String, epoch:String) {
        //let savedDataCount = countFetchFollowersFromCoreData()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // get single follower given ID
        let predicate = NSPredicate(format: "twitter_id == %@", identifier)
        let fetchRequest = NSFetchRequest(entityName: "Follower")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Follower]
            if let follower = fetchedEntities.first {
                follower.epoch = epoch
                
                do {
                    try managedContext.save()
                } catch {
                    // Do something in response to error condition
                }
            } else {
                // Save non existing followers
                let entity =  NSEntityDescription.entityForName("Follower", inManagedObjectContext:managedContext)
                let follower = Follower(entity: entity!, insertIntoManagedObjectContext: managedContext)
                
                follower.twitter_id = identifier
                follower.epoch = epoch
                
                appDelegate.saveContext()
            }
            
        } catch {
            // Do something in response to error condition
            print("error fetching follower with id -> \(identifier)")
        }
    }
    
    func getUnfollowers(epoch:String) {
        print("Unfollowers : ")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        // get single follower given ID
        let predicate = NSPredicate(format: "epoch < %@", epoch)
        let fetchRequest = NSFetchRequest(entityName: "Follower")
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities = try managedContext.executeFetchRequest(fetchRequest) as! [Follower]
            
            for var index = 0; index < fetchedEntities.count; index++ {
                print("\(index) -> \(fetchedEntities[index].twitter_id!) - \(fetchedEntities[index].epoch!)")
                getUserInfo(fetchedEntities[index].twitter_id!)                
            }
            
        } catch {
            print("Error getting unfollowers")
        }
    }
    
    func getUserInfo(twitterId:String) {
        if let userID = Twitter.sharedInstance().sessionStore.session()!.userID {
            let urlString = "https://api.twitter.com/1.1/users/show.json?user_id=" + twitterId
            
            let client = TWTRAPIClient(userID: userID)
            let request = NSURLRequest(URL: NSURL(string: urlString)!)
            
            client.sendTwitterRequest(request) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    let userProfile = UserProfile(twitterNetData: data!)
                    print(userProfile.toString())
                    self.unfollowers.append(userProfile)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    
                    self.unfollowerListView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
                    self.unfollowerListView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
                    self.unfollowerListView.reloadData()
                } else {
                    print("error -> \(error)")
                }
            }
        }
    }
    
    func countFetchFollowersFromCoreData () -> Int {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Follower")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let followers = results as! [NSManagedObject]
            
            return followers.count

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return -1
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "showUnfollowerProfile" {
            if let destination = segue.destinationViewController as? UnfollowerProfileViewController {
                destination.user = unfollowers[selectedIndexPath.row]
            }
        }
    }
}
