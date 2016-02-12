//
//  ViewController.swift
//  TweetBye
//
//  Created by Marc Juberó on 08/02/16.
//
//

import UIKit
import TwitterKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let token = Twitter.sharedInstance().sessionStore.session()?.authToken
        //print("token -> \(token!)")
        
        Twitter.sharedInstance().logInWithCompletion { session, error in
            if (session != nil) {
                //print("signed in as \(session!.userName)");
                self.performSegueWithIdentifier("goToUnfollowersScene", sender: self)
            } else {
                print("error: \(error!.localizedDescription)");
            }
        }
        
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                print("session -> \(unwrappedSession)")
                self.performSegueWithIdentifier("goToUnfollowersScene", sender: self)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        if segueId == "goToUnfollowersScene" {
            //print("goTo unfollowersScene")
        }
    }


}

