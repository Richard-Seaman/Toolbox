//
//  DaylightCalculatorInfoVC.swift
//  BDP Reference App
//
//  Created by Richard Seaman on 05/04/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class DaylightCalculatorInfoVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewController = UITableViewController()
    
    let sectionHeadings:[String] = ["Description", "Room Properties", "Window Properties"]
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    var textFields:[UITextField] = [UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DaylightCalculatorInfoVC.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)

        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0;
        
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        
        // Load the user specified default text field values if a defaults file exists, else load the built in defaults
        loadDaylightDefaults()
        
        // resetDaylightDefaults()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.textFields = [UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField()]
        self.tableView.reloadData()
        
        // Makes sure no keyboard and view reset when it appears
        self.backgroundTapped(self)
        
        // Make sure the nav bar image fits within the new orientation
        if (UIDevice.currentDevice().orientation.isLandscape) {
            if (self.navigationItem.titleView?.frame.height > 400/16) {
                self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
            }
        }
    }
    
    
    // MARK: - Data Persistence
    
    // Save defaults whenever the view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save the values (must be a string array)
        let filePath = dataFilePath()
        
        var stringArray:[String] = [String]()
        for var index = 0; index < daylightCalculatorDefaults.count; index += 1 {
            
            stringArray.append(String(format: "%.2f", daylightCalculatorDefaults[index]))
            
        }
        
        let array = stringArray as NSArray
        array.writeToFile(filePath, atomically: true)
        
        // Prevents keyboard issues
        self.backgroundTapped(self)
    }
    
    
    // MARK: - Tableview methods
    
    // Determine Number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        
        return self.sectionHeadings.count
        
    }
    
    // Assign the rows per section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0: // Description
            return 1
        case 1: // Room properties
            return 8
        case 2: // Window Properties
            return 7
        default:
            return 0
        }
        
    }
    
    
    
    // Set properties of section header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view, colourOption: 4)
        
    }
    
    // Assign Section Header Text
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        return self.sectionHeadings[section]
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //println("cellForRowAtIndexPath \(indexPath.row)")
        var cell:UITableViewCell? = UITableViewCell()
        
        // Method - Variables - Formulae
        
        switch indexPath.section {
            
        case 0: // Description
            
            cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 0
            
            label.text = "This calculation tool is provided as a quick reference guide and should not replace a formal daylight factor calculation.\n\nThe calculation method used is based on rectangular rooms and is capable of handling basic obstructions. The results should not be used for rooms with overhangs, rooms within recesses, or rooms subjected to significant overshadowing. The acceptable daylight factors for schools are used as a reference point.\n\nThe target daylight factor for:\nPrimary School Classrooms = 4.5%\nPost Post School Classrooms = 4.2%"
            
        case 1: // Room Properties
            
            switch indexPath.row {
                
            case 0:
                
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The image below shows the room dimensions that are input on the previous screen relative to the window position. The default room surface reflectances are also provided and can be altered by tapping on the corresponding text box below."
                
            case 1:
                
                cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ImageCell")
                }
                
                let imageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
                let label:UILabel = cell!.viewWithTag(2) as! UILabel
                label.numberOfLines = 0
                
                label.text = "WP = Window Position\n\nL = Room Length (m)\n\nD = Room Depth (m)"
                
                imageView.image = UIImage(named: "Room Plan with labels")
                
            case 2:
                
                cell = tableView.dequeueReusableCellWithIdentifier("CenterCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CenterCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "Room Reflectances"
                
            case 3:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Ceiling (%)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.row = 0
                textfield.placeholder = "80"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 4:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Floor (%)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 1
                textfield.placeholder = "40"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 5:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Walls (%)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 2
                textfield.placeholder = "70"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 6:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Glass (%)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 3
                textfield.placeholder = "10"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 7:
                
                cell = tableView.dequeueReusableCellWithIdentifier("ResetCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ResetCell")
                }
                
                let button:ButtonWithRow = cell!.viewWithTag(1) as! ButtonWithRow
                button.row = 1  // use row to store section
                button.addTarget(self, action: #selector(DaylightCalculatorInfoVC.resetButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                button.layer.borderColor = UIColor.darkGrayColor().CGColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.whiteColor().CGColor
                button.setTitle("Reset", forState: UIControlState.Normal)
                button.tintColor = UIColor.darkGrayColor()
                
            default:
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }
            
        case 2: // Window Properties
            
            switch indexPath.row {
                
            case 0:
                
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The image below shows the window dimensions that are input on the previous screen. An image is also provided to explain the visible sky angle. Again, default values may be altered by tapping on the corresponding text boxes below."
                
            case 1:
                
                cell = tableView.dequeueReusableCellWithIdentifier("ImageCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ImageCell")
                }
                
                let imageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
                let label:UILabel = cell!.viewWithTag(2) as! UILabel
                label.numberOfLines = 0
                
                label.text = "H = Window Height (m)\n\nL = Window Length (m)\n\n\nWP = Window Position\n\nOBS = Obstruction\n\nVSA = Visible Sky Angle (degrees)"
                
                imageView.image = UIImage(named: "Window & VSA Image")
                
            case 2:
                
                cell = tableView.dequeueReusableCellWithIdentifier("CenterCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CenterCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "Defaults"
                
            case 3:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Glazing Transmittance (%)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 4
                textfield.placeholder = "77"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 4:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Visible Sky Angle (degrees)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 5
                textfield.placeholder = "90"
                textfield.text = String(format: "%.1f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
            case 5:
                
                cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "SettingsCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                label.text = "Dirt Correction Factor (-)"
                
                let textfield:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
                textfield.delegate = self
                textfield.row = 6
                textfield.placeholder = "0.90"
                textfield.text = String(format: "%.2f", daylightCalculatorDefaults[textfield.row])
                self.setupTextFieldInputAccessoryView(textfield)
                self.textFields[textfield.row] = textfield
                
                
            case 6:
                
                cell = tableView.dequeueReusableCellWithIdentifier("ResetCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "ResetCell")
                }
                
                let button:ButtonWithRow = cell!.viewWithTag(1) as! ButtonWithRow
                button.row = 2  // use row to store section
                button.addTarget(self, action: #selector(DaylightCalculatorInfoVC.resetButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                button.layer.borderColor = UIColor.darkGrayColor().CGColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.whiteColor().CGColor
                button.setTitle("Reset", forState: UIControlState.Normal)
                button.tintColor = UIColor.darkGrayColor()
                
            default:
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }

            
        default:
            
            // Dummy cell with error
            cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 1
            
            label.text = "This cell should not be here..."
            
        }
        
        
        let background:UIControl = cell!.viewWithTag(9) as! UIControl
        background.addTarget(self, action: #selector(DaylightCalculatorInfoVC.backgroundTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        return cell!
        
    }
    
    
    // MARK: - Button Functions
    
    func resetButtonTapped(sender: ButtonWithRow) {
        
        if (sender.row == 1) {
            print("resetRoomPropertyDefaults")
            resetDaylightRoomProperties()
            
        }
        else {
            print("resetWindowPropertyDefaults")
            resetDaylightWindowProperties()
            
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    // MARK: - Keyboard Functions
    
    // Keyboard Move Screen Up If Required
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    func backgroundTapped(sender:AnyObject) {
        print("Background Tapped")
        var index:Int = Int()
        for index = 0; index < self.textFields.count; index += 1 {
            textFields[index].resignFirstResponder()
            self.keyboardHeightLayoutConstraint.constant = 0
        }
    }
    
    func setupTextFieldInputAccessoryView(sender:UITextField) {
                
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: #selector(DaylightCalculatorInfoVC.applyButtonAction))
        done.tintColor = UIColor.whiteColor()
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        sender.inputAccessoryView = doneToolbar
        
    }
    
    func applyButtonAction()
    {
        self.backgroundTapped(self)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if let actualTextField = textField as? TextFieldWithRow {
            
            self.textFields[actualTextField.row] = actualTextField
            
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if let actualTextField = textField as? TextFieldWithRow {
            
            switch actualTextField.row {
                
            case 5:
                self.checkDegrees(actualTextField)
            case 6:
                self.checkCorrectionFactor(actualTextField)
            default:
                self.checkPercentage(actualTextField)
            }
            
        }
        
    }
    
    
    // MARK: - Data Entry Checks
    
    func checkPercentage(sender: TextFieldWithRow)  {
        
        print("Checking percentage value for TextField \(sender.row)")
        
        let percentage:Float = sender.text!.floatValue
        
        print("Percentage = \(percentage)")
        
        if (percentage >= 0 && percentage <= 100) {
            
            print("Valid")
            
            // If valid, update the defaults
            daylightCalculatorDefaults[sender.row] = percentage
            
        }
        else {
            print("Invalid")
        }
        
        // Update the text with either new or old value
        sender.text = String(format: "%.1f", daylightCalculatorDefaults[sender.row])
        
        print("text updated to: \(sender.text)\n")
        
    }
    
    func checkDegrees(sender: TextFieldWithRow)  {
        
        print("Checking degrees value for TextField \(sender.row)")
        
        let degrees:Float = sender.text!.floatValue
        
        print("Degrees = \(degrees)")
        
        if (degrees >= 0 && degrees <= 90) {
            
            print("Valid")
            
            // If valid, update the defaults
            daylightCalculatorDefaults[sender.row] = degrees
            
        }
        else {
            print("Invalid")
        }
        
        
        // Update the text with either new or old value
        sender.text = String(format: "%.1f", daylightCalculatorDefaults[sender.row])
        
        print("text updated to: \(sender.text)\n")
    }
    
    func checkCorrectionFactor(sender: TextFieldWithRow)  {
        
        print("Checking CF value for TextField \(sender.row)")
        
        let factor:Float = sender.text!.floatValue
        
        print("Factor = \(factor)")
        
        if (factor >= 0 && factor <= 1) {
            
            print("Valid")
            
            // If valid, update the defaults
            daylightCalculatorDefaults[sender.row] = factor
            
        }
        else {
            print("Invalid")
        }
        
        
        sender.text = String(format: "%.2f", daylightCalculatorDefaults[sender.row])
        
        print("text updated to: \(sender.text)\n")
    }
    


}
