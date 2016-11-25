//
//  TimelineViewController.swift
//  post
//
//  Created by José María Delgado  on 23/11/16.
//  Copyright © 2016 José María. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SwiftyJSON
import SAConfettiView
import BubbleTransition

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var tableView: UITableView! = UITableView()
    var refreshController = UIRefreshControl()
    let databaseRef = FIRDatabase.database().reference()
    var posts = [Post]()
    let transition = BubbleTransition()
    
    lazy var newPostButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("\u{e900}", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 100, green: 200, blue: 180)
        button.layer.cornerRadius = 40
        button.titleLabel?.font = UIFont(name: "icons", size: 65)
        button.addTarget(self, action: #selector(goPost), for: .touchUpInside)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 2
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.refreshController.addTarget(self, action: #selector(getInitialPosts), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshController)
        self.tableView.alpha = 0
        self.tableView.separatorStyle = .none
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 100, green: 200, blue: 180).withAlphaComponent(0.9)
        
        transition.duration = 0.3
        
        let confettiView = SAConfettiView(frame: self.view.bounds)
        //view.addSubview(confettiView)
        confettiView.type = .Confetti
        confettiView.intensity = 0.5
        confettiView.startConfetti()
        
      //  self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goPost))
        
        view.addSubview(newPostButton)
        
        newPostButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        newPostButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newPostButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        newPostButton.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        self.getInitialPosts()
    }
    
    func goPost() {
        performSegue(withIdentifier: "uploadPost", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
    }
    
    func getInitialPosts() {
        self.databaseRef.child("posts").queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self.posts = []
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, String> {
                        let post = Post(postKey: snap.key, postDict: postDict)
                        self.posts.append(post)
                    }
                }
                self.posts = self.posts.reversed()
                self.refreshController.endRefreshing()
                self.tableView.reloadData()
                self.tableView.alpha = 1
                //self.animateTableView()
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.postTextLabel.text = self.posts[indexPath.row].postDict["text"]
        cell.postTimeAgoLabel.text = self.getPostTimeAgo(dateString: self.posts[indexPath.row].postDict["timestamp"]!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
    }
    
    func getPostTimeAgo(dateString: String) -> String {
        var timeAgo = String()
        let dateStringUTC = dateString
        let formatToLocal = DateFormatter()
        formatToLocal.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        if let dateFromString = formatToLocal.date(from: dateStringUTC) {
            formatToLocal.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let localStringFromDate = formatToLocal.string(from: dateFromString)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let from = formatter.date(from: localStringFromDate)
            let now = NSDate()
            let components: Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfMonth]
            let difference = NSCalendar.current.dateComponents(components, from: from!, to: now as Date)
            if difference.second! <= 20 {
                print("now")
                timeAgo = "NOW"
            }
            if difference.second! > 20 && difference.minute! == 0 {
                print("\(difference.second)s.")
                let seconds = difference.second! == 1 ? "SECOND" : "SECONDS"
                timeAgo = "\(difference.second!) \(seconds) ago"
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                print("\(difference.minute)m.")
                let minutes = difference.minute == 1 ? "MINUTE" : "MINUTES"
                timeAgo = "\(difference.minute!) \(minutes) AGO"
            }
            if difference.hour! > 0 && difference.day! == 0 {
                print("\(difference.hour)h.")
                let hours = difference.hour == 1 ? "HOUR" : "HOURS"
                timeAgo = "\(difference.hour!) \(hours) AGO"
            }
            if difference.day! > 0 && difference.weekOfMonth! == 0 {
                print("\(difference.day)d.")
                let days = difference.day == 1 ? "DAY" : "DAYS"
                timeAgo = "\(difference.day!) \(days) AGO"
            }
            if difference.weekOfMonth! > 0 {
                print("\(difference.weekOfMonth)w.")
                let weeks = difference.weekOfMonth == 1 ? "WEEK" : "WEEKS"
                timeAgo = "\(difference.weekOfMonth!) \(weeks) AGO"
                if Float(difference.weekOfMonth!) > 52.17 {
                    let number = Float(difference.weekOfMonth!) / 52.17
                    let strYear = String(format:"%.1f", number)
                    print("\(strYear) year")
                    timeAgo = "\(strYear) year"
                }
            }
        }
        return timeAgo
    }
    
    func animateTableView() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("chema")
        self.getInitialPosts()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = self.newPostButton.center
        transition.bubbleColor = self.newPostButton.backgroundColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = self.newPostButton.center
        transition.bubbleColor = self.newPostButton.backgroundColor!
        return transition
    }
    
}

class TableViewCell: UITableViewCell {
    
    var separator: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 245, green: 245, blue: 248)
        return view
    }()
    
    var postTextLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 50
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightThin)
        label.textColor = UIColor.black
        
        return label
        
    }()
    
    var postTimeAgoLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 50
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = UIColor(red: 150, green: 150, blue: 150)
        
        return label
        
    }()
    
    var postPhoto: UIImageView = {
        var imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = UIColor(red: 20, green: 20, blue: 20)
        
        return imageView
    }()
    
    override func awakeFromNib() {
        //contentView.addSubview(postPhoto)
        contentView.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
        contentView.addSubview(postTextLabel)
        contentView.addSubview(postTimeAgoLabel)
        contentView.addSubview(separator)
        
        postTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        postTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        postTextLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -30).isActive = true
        
        postTimeAgoLabel.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -3).isActive = true
        postTimeAgoLabel.leftAnchor.constraint(equalTo: postTextLabel.leftAnchor).isActive = true
        postTimeAgoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        postTimeAgoLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        
    }
    
    
}
