//
//  UserController.swift
//  CKUsersiOS21
//
//  Created by John Tate on 9/26/18.
//  Copyright © 2018 John Tate. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    // shared instance
    static let shared = UserController()
    private init(){}
    
    let currentUserWasSetNotification = Notification.Name("currentUserSet")
    
    // source of truth
    // make optional because might not have anyone logged in currently
    var currentUser: User? {
        didSet {
            NotificationCenter.default.post(name: currentUserWasSetNotification, object: nil)
        }
    }

    // CRUD functions
    func createUserWith(username: String, email: String, completion: ((Bool) -> Void)?) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("There was an error in \(#function) : \(error) \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            guard let recordID = recordID else { completion?(false); return }
            // we use .deleteSelf because if they disconnect from iCloud, we also want to delete them
            let appleUserRef = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            // creating a record locally, so don't have a recordID yet and it will be created by default
            let user = User(username: username, email: email, appleUserRef: appleUserRef)
            // here we use the extension we wrote
            let userRecord = CKRecord(user: user)
            
            CKContainer.default().publicCloudDatabase.save(userRecord, completionHandler: { (record, error) in
                if let error = error {
                    print("There was an error in \(#function) : \(error) \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                
                // if we get a record back from the completion, we know the save to CloudKit worked
                guard let record = record, let user = User(cloudKitRecord: record) else { completion?(false); return }
                
                // set the user equal to the source of truth
                self.currentUser = user
                completion?(true)
            })
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
        // fetch current iCloud account
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let appleUserRecordID = appleUserRecordID else { completion(false); return }
            let appleUserReference = CKRecord.Reference(recordID: appleUserRecordID, action: .deleteSelf)
            
            let predicate = NSPredicate(format: "%K == %@", Constants.appleUserRefKey, appleUserReference)
            let query = CKQuery(recordType: Constants.UserRecordType, predicate: predicate)
            
            CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let record = records?.first else { completion(false); return }
                let user = User(cloudKitRecord: record)
                
                self.currentUser = user
                completion(true)
            })
        }
    }
}
