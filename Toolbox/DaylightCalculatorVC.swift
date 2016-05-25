//
//  DaylightCalculatorVC.swift
//  BDP Reference App
//
//  Created by Richard Seaman on 14/04/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class DaylightCalculatorVC: UIViewController {
    
    
    // TODO: Add dismiss keyboard when info button pressed
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topView: UIControl!
    @IBOutlet weak var roomVariablesView: UIControl!
    @IBOutlet weak var spacingView: UIControl!

    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var schoolSelector: UISegmentedControl!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var roomLengthLabel: UILabel!
    @IBOutlet weak var roomDepthLabel: UILabel!
    @IBOutlet weak var roomHeightLabel: UILabel!
    @IBOutlet weak var windowLengthLabel: UILabel!
    @IBOutlet weak var windowHeightLabel: UILabel!
    
    @IBOutlet var textFields:[UITextField]!             // [Room length, room depth, room height, window length, window height]
    
    // Parameters and default values
    var defaults:[Float] = [7, 7, 3.6, 4, 2.1]            // [Room length, room depth, room height, window length, window height]
    var currentValues:[Float] = [7, 7, 3.6, 4, 2.1]       // Used to replace value if left blank after edit
    var maxLimits:[Float] = [50, 50, 50, 0, 0]          // [Room length, room depth, room height, window length, window height] (max windows depend on room parameters, assign in didLoad)
    var minLimits:[Float] = [1,1,1,0,0]
    
    // Daylight factor ranges and resulting comments for each school type
    var primaryRanges:[Float] = [2.0, 4.5, 5.0]     // if (DF < value) will be used
    var postPrimaryRanges:[Float] = [2.0, 4.2, 5.0]
    var comments:[String] = ["Poor daylight", "Not acceptable for a classroom","Acceptable for a classroom","Excessive daylight"]
    var labelColours:[UIColor] = [UIColor.redColor(), UIColor.orangeColor(), UIColor.greenColor(), UIColor.orangeColor()]
    
    // Track glazing area between functions
    var glazingAreaPercentage:Float = Float()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
        
        var index:Int = Int()
        
        // Make the labels multi-line
        var labels:[UILabel] = [roomLengthLabel, roomDepthLabel, roomHeightLabel, windowLengthLabel, windowHeightLabel]
        for index=0; index < labels.count; index++ {
            labels[index].numberOfLines = 0
        }
        
        // Select post primary as default
        self.schoolSelector.selectedSegmentIndex = 1
        
        roomLengthLabel.text = "Room\nLength"
        roomDepthLabel.text = "Room\nDepth"
        roomHeightLabel.text = "Room\nHeight"
        windowLengthLabel.text = "Window\nLength"
        windowHeightLabel.text = "Window\nHeight"
        
        // Set up the views
        var views:[UIView] = [topView, roomVariablesView]
        for index=0; index < views.count; index++ {
            views[index].layer.backgroundColor = UIColor.whiteColor().CGColor
            if (index == 0) {
                views[index].layer.cornerRadius = 20
            }
            else {
                views[index].layer.cornerRadius = 10
            }
            views[index].layer.borderColor = UIColor.blackColor().CGColor
            views[index].layer.borderWidth = 1
        }
        
        // Add data check, tags, keyboard bar and apply button and default values to textfields
        for index=0; index < textFields.count; index++ {
            textFields[index].text = String(format: "%.1f", defaults[index])
            textFields[index].tag = index
            textFields[index].addTarget(self, action: "checkValue:", forControlEvents: UIControlEvents.EditingDidEnd)
            self.setupTextFieldInputAccessoryView(textFields[index])
        }
        
        // Add update action to segmented control
        self.schoolSelector.addTarget(self, action: "updateCalculation", forControlEvents: UIControlEvents.ValueChanged)
        self.schoolSelector.tintColor = bdpColour
        
        // Update max window dimensions
        self.setMaxWindowSizes()
        
        // Keep track of current values
        for index=0; index < currentValues.count; index++ {
            self.currentValues[index] = self.defaults[index]
        }
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Load daylight defaults
        loadDaylightDefaults()
        
        // Calculate and display daylight factor
        self.updateCalculation()
        
    }

    
    override func viewWillAppear(animated: Bool) {
                
        // Makes sure no keyboard and view reset when it appears
        self.backgroundTapped(self)
        
        // Reload the daylight defaults and recalculate (if returning from defaults page)
        loadDaylightDefaults()
        self.updateCalculation()
        
        // Make sure the nav bar image fits within the new orientation
        if (UIDevice.currentDevice().orientation.isLandscape) {
            if (self.navigationItem.titleView?.frame.height > 400/16) {
                self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.backgroundTapped(self)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func backgroundTapped(sender:AnyObject) {
        var index:Int = Int()
        for index = 0; index < self.textFields.count; index++ {
            textFields[index].resignFirstResponder()
            self.keyboardHeightLayoutConstraint.constant = 0
            contentView.layoutIfNeeded()
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
    
    
    // MARK: - Calculations
    
    func updateCalculation() {
        let daylightFactor:Float = self.calculateDaylightFactor()
        var ranges:[Float] = [Float]()
        
        self.resultLabel.text = String(format: "%.2f%%", daylightFactor)
        
        // Assign the correct range of daylight factors according to the school selected
        if (self.schoolSelector.selectedSegmentIndex == 0) {
            ranges = self.primaryRanges
        }
        else {
            ranges = self.postPrimaryRanges
        }
        
        var daylightFactorPositionInRange:Int = 0
        var index:Int = Int()
        
        for index = 0; index < ranges.count; index++ {
            
            // Find where the daylight factor lies within the range
            if (daylightFactor > ranges[index]) {
                daylightFactorPositionInRange++
            }
        }
        
        self.commentLabel.numberOfLines = 0
        self.commentLabel.text = String(format: "%@\n\nPercentage Glazed Area = %.1f%%", comments[daylightFactorPositionInRange], self.glazingAreaPercentage)
        
        // Colour the result labels according to the result
        self.resultLabel.textColor = self.labelColours[daylightFactorPositionInRange]
        
    }
    
    func calculateDaylightFactor() -> Float {
        
        var daylightFactor:Float = Float()
        
        // Get variables from textFields
        let roomLength:Float = self.textFields[0].text!.floatValue
        let roomDepth:Float = self.textFields[1].text!.floatValue
        let roomHeight:Float = self.textFields[2].text!.floatValue
        let windowLength:Float = self.textFields[3].text!.floatValue
        let windowHeight:Float = self.textFields[4].text!.floatValue
        
        // Calculated Areas
        let ceilingArea = roomDepth * roomLength
        let floorArea = ceilingArea
        let windowArea = windowHeight * windowLength
        let wallsArea = (2 * roomLength + 2 * roomDepth) * roomHeight - windowArea
        
        let totalSurfaceArea = ceilingArea + floorArea + windowArea + wallsArea
        
        // Get stored variables
        // Defaults for calculator = [ceiling, floor, walls, glass, transmittance, VSA, DCF]
        let ceilingReflectance:Float = daylightCalculatorDefaults[0]
        let floorReflectance:Float = daylightCalculatorDefaults[1]
        let wallsReflectance:Float = daylightCalculatorDefaults[2]
        let glazingReflectance:Float = daylightCalculatorDefaults[3]
        
        let glazingTransmittance:Float = daylightCalculatorDefaults[4]
        let visibleSkyAngle:Float = daylightCalculatorDefaults[5]
        let dirtCorrectionFactor:Float = daylightCalculatorDefaults[6]
        
        
        // Calculated Weighted Areas
        let weightedCeilingArea = ceilingArea * ceilingReflectance/100
        let weightedFloorArea = floorArea * floorReflectance/100
        let weightedWindowArea = windowArea * glazingReflectance/100
        let weightedWallsArea = wallsArea * wallsReflectance/100
        
        let areaWeightedReflectance = (weightedCeilingArea + weightedFloorArea + weightedWallsArea + weightedWindowArea) / totalSurfaceArea
        
        // Track percentage of glazing area
        let externalWallArea:Float = roomHeight * roomLength
        self.glazingAreaPercentage = windowArea / externalWallArea * 100
        
        // Calculate daylight factor!
        daylightFactor = (((glazingTransmittance * windowArea * visibleSkyAngle) / (totalSurfaceArea * (1 - areaWeightedReflectance * areaWeightedReflectance))) * dirtCorrectionFactor)/100
        
        return daylightFactor
    }
    
    
    
    // MARK: - Data Entry Checks
    
    func checkValue(sender: UITextField)  {
        
        let value:Float = sender.text!.floatValue
        let maxLimit:Float = self.maxLimits[sender.tag]
        let minLimit:Float = self.minLimits[sender.tag]
        
        // If no value entered, leave current value. If value beyond limits, set to min/max
        if (sender.text == "") {
            sender.text = String(format: "%.1f", currentValues[sender.tag])
        }
        else if (value <= minLimit) {
            sender.text = String(format: "%.1f", minLimit)
            
        }
        else if (value >= maxLimit) {
            sender.text = String(format: "%.1f", maxLimit)
        }
        
        // If room length/height changed, update the window limits and check their values
        if (sender.tag == 0 || sender.tag == 2) {
            self.setMaxWindowSizes()
            self.checkValue(textFields[3])          // Window length
            self.checkValue(textFields[4])          // Window height
        }
        
        // Track the currentValue (if it's not blank)
        if (value > 0) {
            self.currentValues[sender.tag] = value
        }
        
        // Update result
        self.updateCalculation()
        
    }
    
    func setMaxWindowSizes() {
        
        self.maxLimits[3] = self.textFields[0].text!.floatValue      // Set max window length = room length
        self.maxLimits[4] = self.textFields[2].text!.floatValue      // Set max window height = room height
        
    }
    
    
    // MARK: - Navigation


}
