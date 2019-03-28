//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Yaniv Bronshtein on 3/21/19.
//  Copyright © 2019 codepath. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive //dismiss keyboard by dragging down table view
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil) //grab "post office", when event happens(keyboard will hide)
        
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil //clear text every time keyboard is dismissed
        showsCommentBar = false
        becomeFirstResponder()
        
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    //Pulls in post that was just created
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Posts") //create query
        query.includeKeys(["author","comments.author"]) //need to have room for both author and comments. For each comment fetch related author
        query.limit = 20 //Last 20 queries only
        query.findObjectsInBackground() { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //Use nil coalescing operator. If nil set to empty array
        return comments.count + 2 //1 for actual post and one for each comment and add a comment cell
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //Use nil coalescing operator. If nil set to empty array
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
        
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)! //create URL
        
            cell.photoView.af_setImage(withURL: url) //upload image
            
            return cell

        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }

    }
    
    //every time user taps, get callback
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row ==  comments.count + 1 {
            showsCommentBar = true //show comment if row selected
            becomeFirstResponder() // cause re-evaluation
            commentBar.inputTextView.becomeFirstResponder() //raise keyboard. responder = "focus"
        }
//        comment["text"] = "This is a random comment"
//        comment["posts"] = post
//        comment["author"] = PFUser.current()!
//        post.add(comment, forKey: "comments")
//        post.saveInBackground { (success, error) in
//            if success {
//                print("Comment saved")
//            } else {
//                print("Error saving comment")
//            }
//        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //as many sections as you have posts
    }
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.window?.rootViewController = loginViewController
    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
