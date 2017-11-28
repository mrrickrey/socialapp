//
//  FeedVC.swift
//  socialapp
//
//  Created by Enrique Reyes on 3/29/17.
//  Copyright © 2017 Enrique Reyes. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseAuth
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FancyField!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    //declares the cache
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    //ensures an image has been selected on the button
    var imageSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        //init the image picker
        imagePicker = UIImagePickerController()
        //allows cropping of larger images
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
       
        //ref for db post object
        DataService.ds.REF_POST.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }
    
    
    
    //feed table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //returning the amount of objects in posts
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
             return cell
        } else {
            return PostCell()
        }
    }
    
    //image picker function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //sets the image picker buttons image to the users selected image
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        //check several conditions
        guard let caption = captionField.text, caption != "" else {
            //should be a user message prompt
            print("A caption is required")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            //should be a user message
            print("An image must be selected")
            return
        }
        // converting image to image data and compresing for firebase
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            //setting unique identifiers
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metaData, error) in
                
                if error != nil {
                    print("unable to upload to firebase")
                } else {
                    print("successfully uploaded image")
                    let downloadUrl = metaData?.downloadURL()?.absoluteString
                    if let url = downloadUrl {
                        self.postToFirebase(imgUrl: url)
                    }
                    
                
                }
                
            }
        }
        
    }
    
    //post the data to the firebase database
    func postToFirebase(imgUrl: String) {
        
        let post: Dictionary<String, Any> = [
            "caption": captionField.text!,
            "imageUrl": imgUrl,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POST.childByAutoId()
        firebasePost.setValue(post)
        
        //reseting feilds
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        //reload the tableview data
        tableView.reloadData()
        
    }
    
    @IBAction func addImgTapped(_ sender: Any) {
        //presents the image picker
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func singoutTapped(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
        
    }
}
