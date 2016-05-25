//
//  HeatPipeSizerSettingsVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 03/08/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class HeatPipeSizerSettingsVC: UIViewController {

    
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    // Variable View (also used for method view)
    @IBOutlet var variableView: UIControl!
    @IBOutlet weak var tableView: UITableView!
    var textFields: [LoadInfoTF] = [LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF(),LoadInfoTF()]
    var sectionHeadingsVariables: [String] = ["LPHW","CHW","Misc."]
    var sectionHeadingsMethod:[String] = ["Methodology","Set Up","Configuring Loads"]
    
    // Formulae View
    @IBOutlet var formulaeView: UIControl!
    @IBOutlet var webview: UIWebView!
    
    
    // MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPipeSizerProperties()
                
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.selector.addTarget(self, action: "selectorDidChange", forControlEvents: UIControlEvents.ValueChanged)
        self.selector.tintColor = UIColor.darkGrayColor()
        
        self.setUpUI()
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0;
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
        
        // Also includes refresh method
        self.selectorDidChange()
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Save the values
        let filePath = pipeSizerPropertiesFilePath()
        let array = pipeSizerProperties as NSArray
        if (array.writeToFile(filePath, atomically: true)) {
            print("Pipe Sizer Properties saved Successfully")
            
        }
        else {
            print("\nPipe Sizer Properties could not be written to file\n")
            
        }
        
        // Prevents keyboard issues
        self.backgroundTapped(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Set up and user functions
    
    func refresh() {
        print("View refreshed")
        // tap background because tapping reset defaults when on a keyboard will cause a blank screen if you don't dismiss them (done by background tap)
        self.backgroundTapped(self)
        self.tableView.reloadData()
        
    }
    
    func setUpUI() {
        
        // Set background tap
        
        let views:[UIControl] = [self.formulaeView, self.variableView]
        
        for view in views {
            self.addBackgroundTap(view)
        }
        
        let formulaePath:NSURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("PipeSizerFormulae", ofType: "pdf")!)
        
        // Load the formulae into the web view
        self.webview.loadRequest(NSURLRequest(URL: formulaePath))
        
    }
    
    func addBackgroundTap(view:UIControl) {
        
        view.addTarget(self, action: "backgroundTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func selectorDidChange() {
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
            
        case 2:
            self.formulaeView.alpha = 1
            self.variableView.alpha = 0
        default:
            self.formulaeView.alpha = 0
            self.variableView.alpha = 1
        }
        
        self.refresh()
    }
    
    func resetLPHWDefaults() {
        print("resetLPHWDefaults")
        resetLPHWPipeDefaults()
        self.refresh()
    }
    
    func resetCHWDefaults() {
        print("resetCHWDefaults")
        resetCHWPipeDefaults()
        self.refresh()
    }
    
    func resetMiscDefaults() {
        print("resetMiscDefaults")
        resetMiscPipeDefaults()
        self.refresh()
    }
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch self.selector.selectedSegmentIndex {
            
        case 0: // Method
            return 1
            
        case 1: // Variables
            
            switch section {
                
            case 0: // LPHW
                return 5
            case 1: // CHW
                return 5
            case 2: // Misc
                return 4
            default:
                return 0
            }
            
        default: // Formulae
            return 0
            
        }
        
        
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
            
        case 0: // Method
            
            return self.sectionHeadingsMethod.count
            
        case 1: // Variables
            
            return self.sectionHeadingsVariables.count
            
        default: // Formulae
            
            return 0
            
        }
        
    }
    
    
    // Set properties of section header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        
        returnHeader(view, colourOption: 4)
        
        /*
        // Different colours for LPHW & CHW sections
        if (section == 0) {
            // LPHW colour
            returnHeader(view, colourOption: 1)
        }
        else if (section == 1) {
            // CHW colour
            returnHeader(view, colourOption: 2)
        }
        else {
            // Grey Colour
            returnHeader(view, colourOption: 3)
        }
        */
        
    }
    
    // Assign Section Header Text
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
            
        case 0: // Method
            
            return self.sectionHeadingsMethod[section]
            
        case 1: // Variables
            
            return self.sectionHeadingsVariables[section]
            
        default: // Formulae
            
            return ""
            
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //println("cellForRowAtIndexPath \(indexPath.row)")
        
        var cell:UITableViewCell? = UITableViewCell()
        
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
            
        case 0: // Method
            
            if (indexPath.section == 0) {
                
                // Methodology
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "This calculation allows you to size LTHW/CHW pipework.\n\nThe pipes are sized according to the maximum pressure drop selected by the user.\n\nThe formulae and variables used are provided in the tabs at the top of this screen. The variables may be altered using the textfields provided.\n\nThe default values used and the pipework sizes were taken from CIBSE Guide C."
                
            }
            else if (indexPath.section == 1) {
                
                // Set Up
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "You can set the maximum pressure drop to size to and also switch between LPWH/CHW and Steel/Copper pipework by using the textfield and buttons provided in the header section.\n\nThe header section also shows the pipe size and resulting variables for the combined load types (which are configured in the lower section)."
                
            }
            else if (indexPath.section == 2) {
                
                // Configuring Loads
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "There are 6 optional load types that can be configured.\n\nTo configure a load type, you must first input the load or flowrate required. If the load is input, the flowrate will be overwritten and vice versa. Next, the quanitity of this load type must be set by using the textfield or increment buttons provided.\n\nThe pipe size and resulting variables for the total quantity of this load type will be displayed to the right."
                
            }
            else {
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }
            
            
        case 1: // Variables
            
            if (indexPath.row == 4 || (indexPath.section == 2 && indexPath.row == 3)) {   // There's no fifth row in Misc section so this is fine
                
                // Reset defaults button
                cell = tableView.dequeueReusableCellWithIdentifier("PipeSizerButtonCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "PipeSizerButtonCell")
                }
                
                let button:UIButton = cell!.viewWithTag(1) as! UIButton
                let contentView:UIControl = cell!.viewWithTag(2) as! UIControl
                
                // Set background tap
                self.addBackgroundTap(contentView)
                
                button.layer.borderColor = UIColor.darkGrayColor().CGColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.whiteColor().CGColor
                button.setTitle("    Reset Defaults    ", forState: UIControlState.Normal)
                button.tintColor = UIColor.darkGrayColor()
                
                if (indexPath.section == 0) {
                    button.addTarget(self, action: "resetLPHWDefaults", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if (indexPath.section == 1) {
                    button.addTarget(self, action: "resetCHWDefaults", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if (indexPath.section == 2) {
                    button.addTarget(self, action: "resetMiscDefaults", forControlEvents: UIControlEvents.TouchUpInside)
                }
                
                
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("PipeSizerVariableCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "PipeSizerVariableCell")
                }
                
                // Grab the components
                let nameLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                let descLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                let textField:LoadInfoTF = cell!.viewWithTag(3) as! LoadInfoTF
                let contentView:UIControl = cell!.viewWithTag(4) as! UIControl
                
                // Set background tap
                self.addBackgroundTap(contentView)
                
                // Text field set up
                switch indexPath.section {
                    
                case 0, 1, 2: // Each of the sections have editable values (in their textfields)
                    
                    // Add textField to array (and account for different sections)
                    switch indexPath.section {
                        
                    case 0:
                        self.textFields[indexPath.row + 3] = textField
                    case 1:
                        self.textFields[indexPath.row + 7] = textField
                    case 2:
                        self.textFields[indexPath.row] = textField
                    default:
                        print("\n\nTHIS SHOULD NEVER PRINT\nsection: \(indexPath.section) row: \(indexPath.row)\n\nsee cell for row at index path\nAdd text fields to self.textfields\n")
                        
                    }
                    
                    
                    // Set up the textfield
                    textField.indexPath = indexPath
                    textField.row = indexPath.row
                    textField.alpha = 1
                    textField.minimumFontSize = 5
                    textField.adjustsFontSizeToFitWidth = true
                    textField.addTarget(self, action: "textFieldEditingDidEnd:", forControlEvents: UIControlEvents.EditingDidEnd)
                    self.setupTextFieldInputAccessoryView(textField)
                    
                    // Get the property value
                    var floatValue:Float = Float()
                    switch indexPath.section {
                        // See constants file for arrangement of properties within array
                    case 0:
                        floatValue = pipeSizerProperties[indexPath.row + 3]
                    case 1:
                        floatValue = pipeSizerProperties[indexPath.row + 7]
                    case 2:
                        floatValue = pipeSizerProperties[indexPath.row]
                    default:
                        print("\n\nTHIS SHOULD NEVER PRINT\nsection: \(indexPath.section) row: \(indexPath.row)\nsee cell for row at index path\n")
                        
                    }
                    
                    // Set the text field texts
                    if (floatValue <= 0.009) {
                        
                        let formatter = NSNumberFormatter()
                        formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
                        formatter.usesSignificantDigits = false
                        formatter.maximumSignificantDigits = 3
                        formatter.minimumSignificantDigits = 3
                        textField.text = formatter.stringFromNumber(floatValue)
                    }
                    else {
                        textField.text = String(format: "%.2f", floatValue)
                    }
                    
                default:
                    // Hide the non-applicable text fields in each row
                    textField.alpha = 0
                }
                
                // Label set up
                switch indexPath.section {
                    
                case 0, 1: // LPHW & CHW
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = "C"
                        descLabel.text = "Specific heat capacity\n(kJ/kgK)"
                    case 1:
                        nameLabel.text = "rho"
                        descLabel.text = "Density\n(kg/m3)"
                    case 2:
                        nameLabel.text = "vis"
                        descLabel.text = "Viscosity\n(m2/s)"
                    case 3:
                        nameLabel.text = "dT"
                        descLabel.text = "Flow & return temperature difference\n(K)"
                    default:
                        nameLabel.text = ""
                        descLabel.text = ""
                    }
                    
                case 2: // Misc
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = "Pa/m"
                        descLabel.text = "Default maximum pressure drop to size to\n(Pa/m)"
                    case 1:
                        nameLabel.text = "k"
                        descLabel.text = "Steel k value\n(k/mm)"
                    case 2:
                        nameLabel.text = "k"
                        descLabel.text = "Copper k value\n(k/mm)"
                    default:
                        nameLabel.text = ""
                        descLabel.text = ""
                    }
                    
                default:
                    nameLabel.text = ""
                    descLabel.text = ""
                }
            }
            
            
        default: // Formulae
            
            // Dummy cell with error
            cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 1
            
            label.text = "This cell should not be here..."
            
        }
        
        return cell!
        
    }
    
    
    // MARK: - Text Field Functions
    func textFieldEditingDidEnd(sender:LoadInfoTF) {
        print("textFieldEditingDidEnd for section: \(sender.indexPath.section) row: \(sender.indexPath.row)")
        
        var index:Int = Int()
        
        // Adjust the index so that the correct property is changed (see constants for array indexes)
        switch sender.indexPath.section {
            
        case 0:
            index = sender.row + 3
        case 1:
            index = sender.row + 7
        case 2:
            index = sender.row
        default:
            print("\n\nTHIS SHOULD NEVER PRINT\nsee text field editing did end\n")
            
        }
        
        // Check valid entry
        if (sender.text != "" && sender.text!.floatValue >= 0.00000000001) { // dynamic viscoisty is 10^-5
            pipeSizerProperties[index] = sender.text!.floatValue
        }
        
        // Reset the text so that stored value is actually displayed (this is need in case 2 decimal points are entered etc)
        if (pipeSizerProperties[index] <= 0.009) {
            
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.ScientificStyle
            formatter.usesSignificantDigits = false
            formatter.maximumSignificantDigits = 3
            formatter.minimumSignificantDigits = 3
            sender.text = formatter.stringFromNumber(pipeSizerProperties[index])
            
        }
        else {
            sender.text = String(format: "%.2f", pipeSizerProperties[index])
        }
        
    }
    
    
    
    // MARK: - Keyboard Related
    
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
        print("backgroundTapped")
        
        for textField in self.textFields {
            textField.resignFirstResponder()
            self.keyboardHeightLayoutConstraint.constant = 0
        }
        
        
    }
    
    func setupTextFieldInputAccessoryView(sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: Selector("applyButtonAction"))
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
    
    
}
