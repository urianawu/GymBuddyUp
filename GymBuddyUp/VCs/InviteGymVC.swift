//
//  InviteGymVC.swift
//  GymBuddyUp
//
//  Created by you wu on 8/7/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class InviteGymVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var lastGym = Gym()
    var defaultGyms = [Gym(), Gym()]
    var nearbyGyms = [Gym(), Gym(), Gym()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension InviteGymVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if defaultGyms.indexOf({$0.name == lastGym.name}) == nil {
                return defaultGyms.count
            }else {
                return defaultGyms.count + 1
            }
        }else {
            return nearbyGyms.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GymCell", forIndexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
            headerView.backgroundColor = UIColor.flatWhiteColor()
            
            let profileView = UIImageView(frame: CGRect(x: 20, y: 10, width: 30, height: 30))
            profileView.image = UIImage(named: "dumbbell")
            headerView.addSubview(profileView)
            
            let userNameLabel = UILabel(frame: CGRect(x: 60, y: 10, width: 300, height: 30))
            userNameLabel.clipsToBounds = true
            userNameLabel.text = "Gym Nearby"
            
            userNameLabel.font = UIFont.systemFontOfSize(12)
            headerView.addSubview(userNameLabel)
            return headerView
        }
        return nil
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        return 0
    }
}