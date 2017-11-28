//
//  DataService.swift
//  socialapp
//
//  Created by Enrique Reyes on 11/15/17.
//  Copyright © 2017 Enrique Reyes. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper


//holds database url
let DB_BASE = FIRDatabase.database().reference()
//holds storage url
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    
    
    //DB References
    private var _REF_BASE = DB_BASE
    private var _REF_POST = DB_BASE.child("posts") //db post
    private var _REF_USERS = DB_BASE.child("users") //db users
    
    //Storage Reference
    private var _REF_POST_IMG = STORAGE_BASE.child("post-pics") //folder in storage
    
    //securing db private variables
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POST: FIRDatabaseReference {
        return _REF_POST
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    //gets current user
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    //secure storage var
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMG
    }
    
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String> ) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
}
