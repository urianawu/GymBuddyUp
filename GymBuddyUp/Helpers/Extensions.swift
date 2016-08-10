//
//  Extensions.swift
//  GymBuddyUp
//
//  Created by you wu on 7/13/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    func addShadow() {
        let lightColor = ColorScheme.sharedInstance.lightText
        let darkColor = ColorScheme.sharedInstance.darkText
        self.backgroundColor = lightColor
        self.layer.cornerRadius = 5
        //button.clipsToBounds = true
        self.layer.shadowColor = darkColor.CGColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 1
        self.clipsToBounds = true
    }
}
extension UIImageView {
    func makeThumbnail() {
        self.backgroundColor = UIColor.flatGrayColor()
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.flatGrayColor().CGColor
        self.layer.cornerRadius = self.frame.height/2.0
        self.clipsToBounds = true
    }
}

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image.CGImage else { return nil }
        self.init(CGImage: cgImage)
    }
}

extension CVDate {
    public var monthDescription: String {
        get {
            var month = globalDescription
            if let dotRange = month.rangeOfString(",") {
                month.removeRange(dotRange.startIndex..<month.endIndex)
            }
            return month
        }
    }
}

extension UISegmentedControl
{
    
    func makeMultiline(numberOfLines: Int)
    {
        for segment in self.subviews
        {
            let labels = segment.subviews.filter { $0 is UILabel }	// [AnyObject]
            labels.map { ($0 as! UILabel).numberOfLines = numberOfLines }
        }
    }
}
