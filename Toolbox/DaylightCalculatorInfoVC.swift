//
//  DaylightCalculatorInfoVC.swift
//  BDP Reference App
//
//  Created by Richard Seaman on 05/04/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DaylightCalculatorInfoVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewController = UITableViewController()
    
    let sectionHeadings:[String] = ["Overview", "Room Properties", "Window Properties"]
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    var textFields:[UITextField] = [UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(DaylightCalculatorInfoVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.textFields = [UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField()]
        self.tableView.reloadData()
        
        // Makes sure no keyboard and view reset when it appears
        self.backgroundTapped(self)
        
        // Make sure the nav bar image fits within the new orientation
        if (UIDevice.current.orientation.isLandscape) {
            if (self.navigationItem.titleView?.frame.height > 400/16) {
                self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
            }
        }
        
        // Google Analytics
        let name = "Daylight Calculator Settings"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    // MARK: - Data Persistence
    
    // Save defaults whenever the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save the values (must be a string array)
        let filePath = dataFilePath()
        
        var stringArray:[String] = [String]()
        for index in 0 ..< daylightCalculatorDefaults.count {
            
            stringArray.append(String(format: "%.2f", daylightCalculatorDefaults[index]))
            
        }
        
        let array = stringArray as NSArray
        array.write(toFile: filePath, atomically: true)
        
        // Prevents keyboard issues
        self.backgroundTapped(self)
    }
    
    
    // MARK: - Tableview methods
    
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
        return self.sectionHeadings.count
        
    }
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view, colourOption: 4)
        
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        return self.sectionHeadings[section]
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Make sure the header size is what we want
        return defaultHeaderSizae
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        //println("cellForRowAtIndexPath \(indexPath.row)")
        var cell:UITableViewCell? = UITableViewCell()
        
        // Method - Variables - Formulae
        
        switch indexPath.section {
            
        case 0: // Description
            
            cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 0
            
            label.text = "This calculation provides a quick indication of the daylight factor in a room.\n\nThe calculation method used is based on rectangular rooms and is capable of handling basic obstructions. The results should not be used for rooms with overhangs, rooms within recesses, or rooms subjected to significant overshadowing. The acceptable daylight factors for schools are used as a reference point.\n\nThe target daylight factor for:\nPrimary School Classrooms = 4.5%\nPost Post School Classrooms = 4.2%"
            
        case 1: // Room Properties
            
            switch indexPath.row {
                
            case 0:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The image below shows the room dimensions that are input on the previous screen relative to the window position. The default room surface reflectances are also provided and can be altered by tapping on the corresponding text box below."
                
            case 1:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ImageCell")
                }
                
                let imageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
                let label:UILabel = cell!.viewWithTag(2) as! UILabel
                label.numberOfLines = 0
                
                label.text = "WP = Window Position\n\nL = Room Length (m)\n\nD = Room Depth (m)"
                
                imageView.image = UIImage(named: "Room Plan with labels")
                
            case 2:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CenterCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "Room Reflectances"
                
            case 3:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ResetCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ResetCell")
                }
                
                let button:ButtonWithRow = cell!.viewWithTag(1) as! ButtonWithRow
                button.row = 1  // use row to store section
                button.addTarget(self, action: #selector(DaylightCalculatorInfoVC.resetButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.white.cgColor
                button.setTitle("    Reset Defaults    ", for: UIControlState())
                button.tintColor = UIColor.darkGray
                
            default:
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }
            
        case 2: // Window Properties
            
            switch indexPath.row {
                
            case 0:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The image below shows the window dimensions that are input on the previous screen. An image is also provided to explain the visible sky angle. Again, default values may be altered by tapping on the corresponding text boxes below."
                
            case 1:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ImageCell")
                }
                
                let imageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
                let label:UILabel = cell!.viewWithTag(2) as! UILabel
                label.numberOfLines = 0
                
                label.text = "H = Window Height (m)\n\nL = Window Length (m)\n\n\nWP = Window Position\n\nOBS = Obstruction\n\nVSA = Visible Sky Angle (degrees)"
                
                imageView.image = UIImage(named: "Window & VSA Image")
                
            case 2:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CenterCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "Defaults"
                
            case 3:
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "SettingsCell")
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
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ResetCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "ResetCell")
                }
                
                let button:ButtonWithRow = cell!.viewWithTag(1) as! ButtonWithRow
                button.row = 2  // use row to store section
                button.addTarget(self, action: #selector(DaylightCalculatorInfoVC.resetButtonTapped(_:)), for: UIControlEvents.touchUpInside)
                
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.white.cgColor
                button.setTitle("    Reset Defaults    ", for: UIControlState())
                button.tintColor = UIColor.darkGray
                
            default:
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }

            
        default:
            
            // Dummy cell with error
            cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 1
            
            label.text = "This cell should not be here..."
            
        }
        
        
        let background:UIControl = cell!.viewWithTag(9) as! UIControl
        background.addTarget(self, action: #selector(DaylightCalculatorInfoVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        
        
        return cell!
        
    }
    
    
    // MARK: - Button Functions
    
    func resetButtonTapped(_ sender: ButtonWithRow) {
        
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
    func keyboardNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            UIView.animate(withDuration: duration,
                delay: TimeInterval(0),
                options: animationCurve,
                animations: { self.view.layoutIfNeeded() },
                completion: nil)
        }
    }
    
    func backgroundTapped(_ sender:AnyObject) {
        print("Background Tapped")
        var index:Int = Int()        
        for index:Int in 0..<self.textFields.count {
            textFields[index].resignFirstResponder()
            self.keyboardHeightLayoutConstraint.constant = 0
        }
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
                
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(DaylightCalculatorInfoVC.applyButtonAction))
        done.tintColor = UIColor.white
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let actualTextField = textField as? TextFieldWithRow {
            
            self.textFields[actualTextField.row] = actualTextField
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
    
    func checkPercentage(_ sender: TextFieldWithRow)  {
        
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
    
    func checkDegrees(_ sender: TextFieldWithRow)  {
        
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
    
    func checkCorrectionFactor(_ sender: TextFieldWithRow)  {
        
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
