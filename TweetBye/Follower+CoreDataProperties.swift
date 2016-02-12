//
//  Follower+CoreDataProperties.swift
//  TweetBye
//
//  Created by Marc Juberó on 08/02/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Follower {

    @NSManaged var epoch: String?
    @NSManaged var twitter_id: String?

}
