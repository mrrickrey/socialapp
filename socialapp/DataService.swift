//
//  DataService.swift
//  socialapp
//
//  Created by Enrique Reyes on 11/15/17.
//  Copyright © 2017 Enrique Reyes. All rights reserved.
//

import Foundation
import Firebase


//holds database url
let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_POST = DB_BASE.child("posts") //db post
    private var _REF_USERS = DB_BASE.child("users") //db users
    
    //securing private variables
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POST: FIRDatabaseReference {
        return _REF_POST
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String> ) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
}
