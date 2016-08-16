//
//  PlanMainVC.swift
//  GymBuddyUp
//
//  Created by you wu on 6/26/16.
//  Copyright © 2016 You Wu. All rights reserved.
//

import UIKit
import CVCalendar
import KRProgressHUD

class PlanMainVC: UIViewController {
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var monthButton: UIBarButtonItem!
    
    @IBOutlet weak var planLabel: UILabel!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var timeLocView: UIStackView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var workoutButton: UIButton!
    
    var dots = [NSDate]() {
        didSet{
            self.calendarView?.contentController.refreshPresentedMonth()
        }
    }
    var workouts: [ScheduledWorkout]?
    var plan: Plan?
    var selectedDate: NSDate!
    var visibleDate = NSDate()
    var sendTo = 2
    
    let insetColor = ColorScheme.sharedInstance.greyText
    let tintColor = ColorScheme.sharedInstance.buttonTint
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCalendar()
        self.emptyView.hidden = true
        self.planView.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        getPlans()
    }
    
    func setViews(hasPlan: Bool, invited: Bool) {
        workoutButton.hidden = !hasPlan
        timeLocView.hidden = !invited
        emptyView.hidden = hasPlan
        planView.hidden = !hasPlan
        statusView.hidden = !invited
        statusViewHeight.priority = invited ? 250:999
        findButton.hidden = invited
        setStatusBar()
        
    }
    
    func setCalendar() {
        calendarView.backgroundColor = ColorScheme.sharedInstance.calBg
        menuView.backgroundColor = ColorScheme.sharedInstance.calBg
        calendarView.calendarAppearanceDelegate = self
        menuView.delegate = self
        calendarView.delegate = self
        monthButton.title = "< "+CVDate(date: NSDate()).monthDescription
        selectedDate = NSDate()
        getCalendarWorkouts(selectedDate)

    }
    
    func setStatusBar() {
        if sendTo == 1 {
            statusLabel.text = "Searching SideKcK in Buddy List"
        } else if sendTo == 2 {
            statusLabel.text = "Searching SideKcK in Public"
        } else {
            statusLabel.text = " invited"
        }
    }
    
    func getPlans() {
        KRProgressHUD.show()
        
        ScheduledWorkout.getScheduledWorkoutsForDate(selectedDate, complete: { (workouts) in
            print("Retrieved your scheduled workout for date \(self.selectedDate.day)",workouts)
            if workouts.count != 0 {
                self.workouts = workouts
                //get first workout plan detail
                Library.getPlanById(workouts[0].planId, completion: { (plan, error) in
                    guard let plan = plan else {
                        print(error)
                        KRProgressHUD.showError()
                        return
                    }
                    self.plan = plan
                    self.planLabel.text = plan.name
                    Library.getExercisesByPlanId(plan.id, completion: { (exercises, error) in
                        if error == nil {
                            self.plan?.exercises = exercises
                            self.tableView.reloadData()
                            //get plan invitation status
                            self.setViews(true, invited: false)
                            KRProgressHUD.dismiss()
                        }else {
                            KRProgressHUD.showError()
                        }
                    })
                    
                })
                
            }else {
                self.setViews(false, invited: false)
                
                KRProgressHUD.dismiss()
            }
            
        })
    }
    
    func getCalendarWorkouts (date: NSDate) {
        print("getting calendar dots \(date.month)")
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate: date)
        let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        let numDays = range.length
        
        for day in 1...numDays {
            components.day = day
            guard let thisday = calendar.dateFromComponents(components) else {return}
            ScheduledWorkout.getScheduledWorkoutsForDate(thisday) { (workouts) in
                if workouts.count != 0 {
                    self.dots.append(thisday)
                }
            }

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func unwindToPlanMainVC(segue: UIStoryboardSegue) {
        
    }
    @IBAction func onMonthButton(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
        UIView.animateWithDuration(0.3, animations: {
            self.emptyView.alpha = 0
            self.planView.alpha = 0
        })
    }
    @IBAction func onTodayButton(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
        calendarView.toggleCurrentDayView()
        calendarView.contentController.performedDayViewSelection()
    }
    
    @IBAction func onMoreButton(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let repeating = self.workouts![0].recur == 7
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            //delete
            if repeating {
                let deleteController = UIAlertController(title: nil, message: "This is a repeating plan.", preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                deleteController.addAction(cancelAction)
                let DeleteAllAction = UIAlertAction(title: "Delete All Future Plans", style: .Destructive) { (action) in
                    ScheduledWorkout.stopRecurringWorkoutOnDate(self.workouts![0].id, stopOnDate: self.selectedDate, completion: { (error) in
                        print("deleted all future plans")
                        self.getPlans()
                    })
                }
                deleteController.addAction(DeleteAllAction)
                let DeleteThisAction = UIAlertAction(title: "Delete This Plan Only", style: .Destructive) { (action) in
                    ScheduledWorkout.skipScheduledWorkoutForDate(self.workouts![0].id, date: self.selectedDate, completion: { (error) in
                        print("deleye this plan only")
                        self.getPlans()
                    })
                }
                deleteController.addAction(DeleteThisAction)
                self.presentViewController(deleteController, animated: true, completion: nil)
            }else {
                //should call delete instead
                ScheduledWorkout.stopRecurringWorkoutOnDate(self.workouts![0].id, stopOnDate: self.selectedDate, completion: { (error) in
                    print("deleted all future plans")
                    self.getPlans()
                })
            }
        }
        alertController.addAction(DeleteAction)
        
        let ReplaceAction = UIAlertAction(title: "Replace", style: .Default) { (action) in
            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        }
        alertController.addAction(ReplaceAction)
        
        let RepeatAction = UIAlertAction(title: "Repeat Weekly", style: .Default) { (action) in
            //set plan as repeat
            
        }
        if !repeating {
            alertController.addAction(RepeatAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func onCancelInviteButton(sender: AnyObject) {
        print("cancel invite")
        var message = ""
        if sendTo == 1 || sendTo == 2{
            message = "Cancel broadcasting?"
        }else {
            message = "Cancel invitation?"
        }
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "No, Keep it", style: .Cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Yes", style: .Destructive) { (action) in
            //cancel invitation
            self.setViews(true, invited: false)
        }
        alertController.addAction(confirmAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onNewPlanButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        //        let alertController = UIAlertController(title: nil, message: "New Plan", preferredStyle: .ActionSheet)
        //
        //        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        //            // ...
        //        }
        //        alertController.addAction(cancelAction)
        //
        //        let BuildAction = UIAlertAction(title: "Build your own", style: .Default) { (action) in
        //            self.performSegueWithIdentifier("toBuildPlanSegue", sender: self)
        //        }
        //        alertController.addAction(BuildAction)
        //
        //        let LibAction = UIAlertAction(title: "SideKck training library", style: .Default) { (action) in
        //            self.performSegueWithIdentifier("toPlanLibrarySegue", sender: self)
        //        }
        //        alertController.addAction(LibAction)
        //
        //        self.presentViewController(alertController, animated: true) {
        //            // ...
        //        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier ==  "toExerciseDetailSegue" {
            if let desVC = segue.destinationViewController as? PlanExerciseVC {
                if let plan = plan, exercises = plan.exercises {
                    desVC.exercise = exercises[sender as! Int]
                }
            }
        }
        if segue.identifier == "toPlanLibrarySegue" {
            if let desVC = segue.destinationViewController as? PlanLibNavVC {
                desVC.selectedDate = selectedDate
            }
        }
        
    }
    
    
}

extension PlanMainVC: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode {
        return .WeekView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    // MARK: Optional methods
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }

    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }
    
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDate = dayView.date.convertedDate()
        getPlans()
        calendarView.changeMode(.WeekView)
        UIView.animateWithDuration(0.3, animations: {
            self.emptyView.alpha = 1
            self.planView.alpha = 1
        })
    }
    
    func presentedDateUpdated(date: CVDate) {
        visibleDate = date.convertedDate()!
        if monthButton.title != date.monthDescription {
            getCalendarWorkouts(date.convertedDate()!)
            //monthButton.alpha = 0
            UIView.animateWithDuration(0.3, animations: {
                self.monthButton.title = "< "+date.monthDescription
            })
        }
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        if dayView.date.month == visibleDate.month {
            let date = dayView.date.convertedDate()
            if self.dots.contains(date!) {
                return true
            }
        }
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        
        let color = ColorScheme.sharedInstance.calText
        
        return [color] // return 1 dot
        
    }
    
    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 5
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    
    
}

extension PlanMainVC: CVCalendarViewAppearanceDelegate {
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dayLabelWeekdayOutTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calTextDark
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calBg
    }
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return ColorScheme.sharedInstance.calBg
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
    func dotMarkerColor() -> UIColor {
        return ColorScheme.sharedInstance.calText
    }
    
}

extension PlanMainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let plan = plan, exercises = plan.exercises {
            return exercises.count
        }else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ExerciseCell", forIndexPath: indexPath) as! ExerciseNumberedCell
        cell.numLabel.text = String(indexPath.row+1)
        if let plan = plan, exercises = plan.exercises {
            cell.exercise = exercises[indexPath.row]
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toExerciseDetailSegue", sender: indexPath.row)
    }
}

