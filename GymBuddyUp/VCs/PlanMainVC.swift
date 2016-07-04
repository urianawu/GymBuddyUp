//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit

class PlanMainVC: UIViewController {
    @IBOutlet weak var calCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        calCollectionView.dataSource = self
        calCollectionView.delegate = self
        // Do any additional setup after loading the view.
        setNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavBar() {
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        space.width = 50
        let prevButton = UIBarButtonItem(title: "<", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        let nextButton = UIBarButtonItem(title: ">", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        let calButton = UIBarButtonItem(title: "Cal", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        self.navigationItem.setLeftBarButtonItems([space, prevButton], animated: true)
        self.navigationItem.setRightBarButtonItems([calButton, space, nextButton], animated: true)
    }
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        
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

extension PlanMainVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 14
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dateCell = collectionView.dequeueReusableCellWithReuseIdentifier("DateCell", forIndexPath: indexPath)
        return dateCell
    }
}