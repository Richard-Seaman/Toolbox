//
//  DuctSizerVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 22/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class DuctSizerVC: UIViewController {
    
    @IBOutlet var backGroundControlViews: [UIControl]!
    
    // Flowrate outlets
    @IBOutlet weak var flowratePerSecondTextField: UITextField!
    @IBOutlet weak var flowratePerHourTextField: UITextField!
    
    @IBOutlet weak var areaTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var achTextField: UITextField!
    
    @IBOutlet weak var flowrateView: UIView!
    @IBOutlet weak var achView: UIView!
    
    
    // Duct outlets
    @IBOutlet weak var ductButton: UIButton!
    
    @IBOutlet weak var ductShapeView: UIView!
    
    @IBOutlet weak var xLockButton: UIButton!
    @IBOutlet weak var yLockButton: UIButton!
    
    @IBOutlet weak var xTextField: UITextField!
    @IBOutlet weak var yTextField: UITextField!    
    
    @IBOutlet weak var pdLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var aspectLabel: UILabel!
    
    @IBOutlet weak var xSlider: UISlider!{
        didSet{
            // xSlider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI)) // rotate if you want slide from left to right
        }
    }
    @IBOutlet weak var ySlider: UISlider!{
        didSet{
            ySlider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        }
    }
    
    @IBOutlet weak var ySliderView: UIView!
    
    @IBOutlet weak var xHighlighterView: UIView!
    @IBOutlet weak var yHighlighterView: UIView!    
    
    
    // Autosize Outlets
    @IBOutlet weak var bottomAutoSizeView: UIControl!
    @IBOutlet weak var velocitySelector: UISegmentedControl!
    @IBOutlet weak var autoSizeButton: UIButton!
    @IBOutlet weak var velocityTextField: UITextField!
    @IBOutlet weak var aspectTextField: UITextField!
    
    
    // UI outlets
    @IBOutlet  var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var textFields:[UITextField]! // Just for tap background method
    
    
    // Constants to use
    let minDim:Float = 100
    let maxDim:Float = 1000
    let increment:Float = 50
    
    let shaded:CGFloat = 0.3
    
    let pi:Float = Float(M_PI)
    
    // Variables to use
    // var flowrateSecond:Float? = nil     // m3/s
    // var flowrateHour:Float? = nil       // m3/hr
    
    var area:Float? = nil               // m2
    var height:Float? = nil             // m
    
    var ach:Float? = nil                // ACH
    
    var flowrateToUse:Float? = nil      // m3/s
    
    var xDimension:Float = Float()      // mm
    var yDimension:Float = Float()      // mm
    var diameter:Float = Float()        // mm
    
    var rectVelocity:Float? = nil       // m/s
    var rectPd:Float? = nil             // Pa/m
    var circVelocity:Float? = nil       // m/s
    var circPd:Float? = nil             // Pa/m
    var aspect:Float = Float()          // -
    
    var autosizeVelocity:[Float?] = [nil,1.5,3.5,6]   // m/s
    var autosizeAspect:Float? = nil                   // -
    
    var xLocked:Bool = Bool(){
        didSet{
            self.lockChanged(self.xLockButton)
        }
    }
    var yLocked:Bool = Bool(){
        didSet{
            self.lockChanged(self.yLockButton)
        }
    }
    

    // MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDuctSizerProperties()
        
        // Listen for keyboard changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
        
        // Initally set to flowrate view
        self.flowrateView.alpha = 1
        self.achView.alpha = 1
        
        let topViews:[UIView] = [self.flowrateView, self.achView]
        for view in topViews {
            view.layer.borderColor = UIColor.darkGrayColor().CGColor
            view.layer.borderWidth = 1
        }
        
        // Unlock dimensions
        self.xLocked = false
        self.yLocked = false
        
        // Set up duct change buttons & initally set to rect
        self.setUpButtons()
        self.ySlider.alpha = 0  // this and next line will force to rect
        self.ductButtonTapped()
        
        // Set up the text fields
        for textField in self.textFields {
            self.setupTextFieldInputAccessoryView(textField)
            textField.addTarget(self, action: "textFieldEditingDidEnd:", forControlEvents: UIControlEvents.EditingDidEnd)
        }
        
        // Apply the background tap function to the backgrounds
        for view in self.backGroundControlViews {
            view.addTarget(self, action: "backgroundTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        // Set up the sliders
        let sliders:[UISlider] = [self.xSlider, self.ySlider]
        for slider in sliders {
            slider.addTarget(self, action: "sliderDidChange:", forControlEvents: UIControlEvents.ValueChanged)
            slider.addTarget(self, action: "sliderTouched:", forControlEvents: UIControlEvents.TouchDown)
            slider.addTarget(self, action: "sliderReleased:", forControlEvents: UIControlEvents.TouchUpInside)
            slider.addTarget(self, action: "sliderReleased:", forControlEvents: UIControlEvents.TouchUpOutside)
        }
        
        // Set up the velocity selector
        self.velocitySelector.addTarget(self, action: "velocitySelectorDidChange:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Set up th highlight views
        let highlightViews:[UIView] = [self.xHighlighterView, self.yHighlighterView]
        for view in highlightViews {
            view.layer.cornerRadius = 3
            view.clipsToBounds = true
            view.alpha = 0
        }
        
        // Set the background colour of the views
        let colouredViews:[UIView] = [self.achView, self.flowrateView, self.xHighlighterView, self.yHighlighterView, self.bottomAutoSizeView]
        for view in colouredViews {
            
            view.backgroundColor = bdpColour
            
        }
        
        // Set the initial values
        self.setInitialValues()
        
        // Set up is finished, refresh the view
        self.refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(animated: Bool) {
        self.backgroundTapped(self)
    }
    
    
    
    // MARK: - Set Up
    
    func setInitialValues() {
        
        print("setInitialValues")
        
        self.flowrateToUse = nil
        
        self.xDimension = 500
        self.yDimension = 500
        self.diameter = self.xDimension
        
        self.calculateAspectRatio()
        
        // SLIDER POSITIONS
        let yPosition:Float = self.yDimension / (self.maxDim - self.minDim)
        self.ySlider.value = yPosition
        
        if (ySlider.alpha == 1) {
            // Rectangular duct
            let xPosition:Float = self.xDimension / (self.maxDim - self.minDim)
            self.xSlider.value = xPosition
        }
        else {
            // Circular duct
            let xPosition:Float = self.diameter / (self.maxDim - self.minDim)
            self.xSlider.value = xPosition
        }
        
    }
    
    func setUpButtons() {
        
        // Add methods
        self.ductButton.addTarget(self, action: "ductButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.autoSizeButton.addTarget(self, action: "autosizeButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.xLockButton.addTarget(self, action: "lockTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.yLockButton.addTarget(self, action: "lockTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // Change autosize appearance
        self.autoSizeButton.setTitle("Autosize", forState: UIControlState.Normal)
        self.autoSizeButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.autoSizeButton.layer.borderWidth = 2.5
        self.autoSizeButton.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.autoSizeButton.layer.cornerRadius = self.ductButton.frame.size.height/3
        self.autoSizeButton.clipsToBounds = true
        
        // Get rid of lock button titles
        self.xLockButton.setTitle("", forState: UIControlState.Normal)
        self.yLockButton.setTitle("", forState: UIControlState.Normal)
        
    }
    
    func lockChanged(sender:UIButton) {
        
        let greenColour:UIColor = UIColor(red: 100/255, green: 180/255, blue: 0/255, alpha: 1)
        let redColour:UIColor = UIColor.redColor()
        
        // Called whenever xLocked or yLocked is changed
        
        if (sender == self.xLockButton) {
            
            if (self.xLocked) {
                self.xLockButton.setImage(UIImage(named: "Locked"), forState: UIControlState.Normal)
                self.xLockButton.tintColor = redColour
                self.xSlider.userInteractionEnabled = false
                self.xSlider.alpha = shaded
                //if (self.yLocked) {self.yLocked = false}    // Only 1 side locked at a time
            }
            else {
                self.xLockButton.setImage(UIImage(named: "Unlocked"), forState: UIControlState.Normal)
                self.xLockButton.tintColor = greenColour
                self.xSlider.userInteractionEnabled = true
                self.xSlider.alpha = 1
            }
            
        }
        else if (sender == self.yLockButton) {
            
            if (self.yLocked) {
                self.yLockButton.setImage(UIImage(named: "Locked"), forState: UIControlState.Normal)
                self.yLockButton.tintColor = redColour
                self.ySlider.userInteractionEnabled = false
                self.ySlider.alpha = shaded
                //if (self.xLocked) {self.xLocked = false}    // Only 1 side locked at a time
            }
            else {
                self.yLockButton.setImage(UIImage(named: "Unlocked"), forState: UIControlState.Normal)
                self.yLockButton.tintColor = greenColour
                self.ySlider.userInteractionEnabled = true
                self.ySlider.alpha = 1
            }
        }
        
        print("xLocked = \(self.xLocked)\nyLocked = \(self.yLocked)")
    }
    
    // MARK: - UI
    
    func refresh() {
        
        print("refresh")
        
        self.setAspectRatioAlpha()
        
        // Recalculate
        self.calculateAspectRatio()
        self.calculate()
        
        
        // Update the textfield and label texts
        self.updateTextsAndLabels()
        
    }
    
    
    func updateTextsAndLabels() {
        
        print("updateTextsAndLabels")
        
        
        // FLOWRATE INPUTS
        
        // Flowrate textfields
        if let flowrate = self.flowrateToUse {
            self.flowratePerHourTextField.text = String(format: "%.0f", flowrate * 3600)
            self.flowratePerSecondTextField.text = String(format: "%.2f", flowrate)
            if (self.area != nil && self.height != nil) {
                self.achTextField.text = String(format: "%.1f", flowrate * 3600 / (self.area! * self.height!))
            }
        }
        else {
            self.flowratePerSecondTextField.text = ""
            self.flowratePerHourTextField.text = ""
            if let actualAch = self.ach {
                self.achTextField.text = String(format: "%.1f", actualAch)
            }
            else {
                self.achTextField.text = ""
            }
            
        }
        // Length Textfield
        if let actualArea = self.area {
            self.areaTextField.text = String(format: "%.2f", actualArea)
        }
        else {
            self.areaTextField.text = ""
        }
        // Height Textfield
        if let actualHeight = self.height {
            self.heightTextField.text = String(format: "%.2f", actualHeight)
        }
        else {
            self.heightTextField.text = ""
        }
        
        
        
        // RESULTS
        
        // Dimension labels
        if (self.ySlider.alpha != 0) {
            self.xTextField.text = String(format: "%.0f", self.xDimension)
        }
        else {
            self.xTextField.text = String(format: "%.0f", self.diameter)
        }
        
        self.yTextField.text = String(format: "%.0f", self.yDimension)
        // self.diameterTextField.text = String(format: "%.0f", self.xDimension)
        
        // Check what's displayed
        var resultVelocity:Float? = Float()
        var resultPd:Float? = Float()
        if (self.ySlider.alpha != 0) {
            resultVelocity = self.rectVelocity
            resultPd = self.rectPd
        }
        else {
            resultVelocity = self.circVelocity
            resultPd = self.circPd
        }
        
        // Velocity label
        if let actualVelocity = resultVelocity {
            self.velocityLabel.text = String(format: "%.2f m/s", actualVelocity)
        }
        else {
            self.velocityLabel.text = "-- m/s"
        }
        // Pressure drop label
        if let actualPd = resultPd {
            self.pdLabel.text = String(format: "%.2f Pa/m", actualPd)
        }
        else {
            self.pdLabel.text = "-- Pa/m"
        }
        
        // Aspect label
        self.aspectLabel.text = String(format: "%.2f", self.aspect)
        
        if (self.xDimension >= self.yDimension) {
            self.aspectLabel.text = self.aspectLabel.text! + " (x/y)"
        }
        else{
            self.aspectLabel.text = self.aspectLabel.text! + " (y/x)"
        }
        
        
        
        // AUTOSIZE INPUTS
        
        // m/s Textfield
        if let actualVelocity = self.autosizeVelocity[self.velocitySelector.selectedSegmentIndex] {
            self.velocityTextField.text = String(format: "%.2f", actualVelocity)
        }
        else {
            self.velocityTextField.text = ""
        }
        // Pa/m Textfield
        if let actualAspect = self.autosizeAspect {
            self.aspectTextField.text = String(format: "%.2f", actualAspect)
        }
        else {
            self.aspectTextField.text = ""
        }
        
    }
    
    
    // MARK: - Calculations
    
    func calculate() {
        
        if let flowrate = self.flowrateToUse {
            
            // Properties
            let rho:Float = ductSizerProperties[0]
            let visco:Float = ductSizerProperties[1]
            let k:Float = ductSizerProperties[2]
            
            // Dimensions
            let q:Float = flowrate                  // m3/s
            let x:Float = self.xDimension / 1000    // m
            let y:Float = self.yDimension / 1000    // m
            let d:Float = self.diameter / 1000      // m
            let dh:Float  = (2*x*y)/(x+y)           // m - Equivalent diameter
            
            var aspect:Float = Float()
            
            if (x/y >= 1) {
                aspect = x/y
            }
            else {
                aspect = y/x
            }
            
            // Velocities
            let rectV:Float  = q / (x * y)             // m/s
            let circV:Float  = (q * 4.0) / (d * d * pi)  // m/s
            
            
            // Pd sub variables (formula is quite long)
            
            // Circ
            let a:Float = 6.9 / ((rho * circV * d) / visco) + powf((k/1000) / (3.71 * d), 1.11)
            
            let b:Float = -1.8 * log10(a)
            
            let c:Float = (0.5 * rho * circV * circV) / d
            
            // Rect
            
            let l:Float = 6.9 / ((rho * rectV * dh) / visco) + powf((k/1000) / (3.71 * dh), 1.11)
            
            let m:Float = -1.8 * log10(l)
            
            let n:Float = (0.5 * rho * rectV * rectV) / dh
            
            
            // Pressure drops
            self.circPd = powf(1/b, 2) * c    // Pa/m
            self.rectPd = powf(1/m, 2) * n    // Pa/m
            
            // Update the velocities
            self.rectVelocity = rectV
            self.circVelocity = circV
            
        }
        
        
        
    }
    
    func calculateAspectRatio() {
        
        if (self.xDimension >= self.yDimension) {
            self.aspect = self.xDimension/self.yDimension
        }
        else {
            self.aspect = self.yDimension/self.xDimension
        }
        
    }
    
    func autosize(velocity:Float, aspect:Float?) {
        
        // Have already checked that both dimensions are not locked
        // Also, whenever circ duct is selected, both Dims are unlocked
        
        
        // Rectangular duct
        
        if (self.xLocked) {
            
            // Can't change x dim
            
            // Set minimum dimensions
            var y:Float = self.minDim / 1000
            let x:Float = self.xDimension / 1000
            
            let q:Float = self.flowrateToUse!
            
            var v:Float = q / (x*y)
            
            while v > velocity {
                
                y = y + self.increment / 1000
                
                v = q / (x * y)
                
            }
            
            self.yDimension = y * 1000
            
        }
        else if (self.yLocked) {
            
            // Can't change y dim
            
            // Set minimum dimensions
            let y:Float = self.yDimension / 1000
            var x:Float = self.minDim / 1000
            
            let q:Float = self.flowrateToUse!
            
            var v:Float = q / (x*y)
            
            while v > velocity {
                
                x = x + self.increment / 1000
                
                v = q / (x * y)
                
            }
            
            self.xDimension = x * 1000
            
        }
        else {
            // No restrictions
            
            // Set minimum dimensions
            var y:Float = self.minDim / 1000
            var x:Float = Float()
            if let actualAspect = aspect {
                x = y * actualAspect
            }
            else {
                x = self.minDim / 1000
            }
            
            let q:Float = self.flowrateToUse!
            
            var v:Float = q / (x*y)
            
            while v > velocity {
                
                // if no aspect, increment duct sides in turn
                if (aspect == nil) {
                    
                    // Increment y first
                    y = y + self.increment / 1000
                    
                    // Check v
                    v = q / (x * y)
                    
                    if (v > velocity) {
                        // Increment x too
                        x = x + self.increment / 1000
                        v = q / (x * y)
                    }
                    
                }
                // if aspect provided, you're limited in how you expand
                else {
                    
                    y = y + self.increment / 1000
                    x = y * aspect!
                    v = q / (x * y)
                }
                
            }
            
            self.xDimension = x * 1000
            self.yDimension = y * 1000
        }
        
        
        // Circular duct
        
        // Set minimum dimensions
        var d:Float = self.minDim / 1000
        
        let q:Float = self.flowrateToUse!
        
        var v:Float = (q * 4) / (d * d * pi)
        
        while v > velocity {
            
            d = d + self.increment / 1000
            
            v = (q * 4) / (d * d * pi)
            
        }
        
        self.diameter = d * 1000
        
        
        
        // Check what's displayed
        if (self.ySlider.alpha != 0) {
            self.xSlider.value = (self.xDimension - self.minDim) / (self.maxDim - self.minDim)
        }
        else {
            self.xSlider.value = (self.diameter - self.minDim) / (self.maxDim - self.minDim)
        }
        
        self.ySlider.value = (self.yDimension - self.minDim) / (self.maxDim - self.minDim)
        
        self.refresh()
        
    }
    
    
    // MARK: - TextField Functions
    
    func textFieldEditingDidEnd(sender:UITextField) {
        
        print("textFieldEditingDidEnd")
        
        // Check for blank entry
        if (sender.text != "") {
            
            var newValue:Float? = sender.text!.floatValue
            if (newValue == 0) {
                print("0 entered, setting value to nil")
                newValue = nil
            }
            
            // Check which text field's value was changed and update the variables accordingly
            switch sender {
            case self.flowratePerSecondTextField:
                self.updateFlowrate(sender)
            case self.flowratePerHourTextField:
                self.updateFlowrate(sender)
            case self.areaTextField:
                self.area = newValue
                self.updateFlowrate(sender)
            case self.heightTextField:
                self.height = newValue
                self.updateFlowrate(sender)
            case self.achTextField:
                self.ach = newValue
                self.updateFlowrate(sender)
            case self.xTextField:
                if (sender.text!.floatValue != 0 && sender.text != "") {
                    self.xDimension = sender.text!.floatValue
                }
                else {
                    sender.text = String(format: "%.2f", self.xDimension)
                }
            case self.yTextField:
                if (sender.text!.floatValue != 0 && sender.text != "") {
                    self.yDimension = sender.text!.floatValue
                }
                else {
                    sender.text = String(format: "%.2f", self.yDimension)
                }
            case self.velocityTextField:
                // Set the value and autosize if flowrate provided
                self.autosizeVelocity[0] = newValue
                if (self.flowrateToUse != nil && newValue != nil) {
                    self.autosizeButtonTapped()
                }
            case self.aspectTextField:
                // Set the value and autosize if there's a velocity and flowrate
                self.autosizeAspect = newValue
                if (self.autosizeVelocity[self.velocitySelector.selectedSegmentIndex] != nil && self.flowrateToUse != nil) {
                    self.autosizeButtonTapped()
                }
            default:
                print("Could not find matching Text Field to update value")
            }
            
        }
        
        self.refresh()
        
    }
    
    func updateFlowrate(sender:UITextField) {
        
        let shade:CGFloat = 0.5
        
        if (self.area != nil && self.height != nil && self.ach != nil && sender != self.flowratePerSecondTextField && sender != self.flowratePerHourTextField) {
            
            // Use the ACH flowrate
            self.flowrateToUse = self.area! * self.height! * self.ach! / 3600
            self.achView.alpha = 1
            self.flowrateView.alpha = shade
            
        }
        else if (sender == self.flowratePerHourTextField) {
            
            // Use flowrate per hour
            if (sender.text!.floatValue != 0 && sender.text != "") {
                self.flowrateToUse = sender.text!.floatValue / 3600
                self.achView.alpha = shade
                self.flowrateView.alpha = 1
            }
            
        }
        else if (sender == self.flowratePerSecondTextField) {
            
            // Use the flowrate per second
            if (sender.text!.floatValue != 0 && sender.text != "") {
                self.flowrateToUse = sender.text!.floatValue
                self.achView.alpha = shade
                self.flowrateView.alpha = 1
            }
        }
        
        // Autosize if flowrate and velocity have been provided
        if (self.autosizeVelocity[self.velocitySelector.selectedSegmentIndex] != nil && self.flowrateToUse != nil) {
            self.autosizeButtonTapped()
        }
        
    }
    
    
    // MARK: - Slider & Selector Functions
    
    func sliderDidChange(sender:UISlider) {
        
        // Get value
        var newDim:Float = (self.maxDim - self.minDim) * sender.value + self.minDim
        
        let remainder:Float = newDim % self.increment
        let smallerSize:Float = (newDim - remainder)
        
        if (remainder >= self.increment/2) {
            // Round up
            newDim = smallerSize + self.increment
        }
        else {
            // Round down
            newDim = smallerSize
        }
        
        if (sender == self.ySlider) {
            self.yDimension = newDim
        }
        else if (sender == self.xSlider) {
            self.xDimension = newDim
            self.diameter = newDim
        }
        
        self.refresh()
        
    }
    
    func sliderTouched(sender:UISlider) {
        
        if (sender == self.xSlider) {
            print("xSlider touched")
            self.xHighlighterView.alpha = 1
        }
        else if (sender == self.ySlider) {
            print("ySlider touched")
            self.yHighlighterView.alpha = 1
        }
        
    }
    
    func sliderReleased(sender:UISlider) {
        
        if (sender == self.xSlider) {
            print("xSlider released")
            self.xHighlighterView.alpha = 0
        }
        else if (sender == self.ySlider) {
            print("ySlider released")
            self.yHighlighterView.alpha = 0
        }
        
    }
    
    func velocitySelectorDidChange(sender:UISegmentedControl) {
        
        print("velocitySelectorDidChange")
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.velocityTextField.userInteractionEnabled = true
            self.velocityTextField.alpha = 1
        default:
            self.velocityTextField.userInteractionEnabled = false
            self.velocityTextField.alpha = 0.8
            
        }
        
        if let velocity = self.autosizeVelocity[self.velocitySelector.selectedSegmentIndex] {
            self.velocityTextField.text = String(format: "%.2f", velocity)
        }
        else {
            self.velocityTextField.text = ""
        }
        
        if let aspect = self.autosizeAspect {
            self.aspectTextField.text = String(format: "%.2f", aspect)
        }
        else {
            self.aspectTextField.text = ""
        }

        // If a tab with a velocity is selected, automatically autosize
        if (self.autosizeVelocity[sender.selectedSegmentIndex] != nil) {
            
            // Check that flowrate provided first
            if (self.flowrateToUse != nil) {
                self.autosizeButtonTapped()
            }
            
        }
        
    }
    
    // MARK: - Button Functions

    func ductButtonTapped() {
        
        print("ductButtonTapped")
        
        if (self.ySlider.alpha == 0) {
            
            // Circular duct selected - change to rectangular
            
            // Set duct shape
            self.ductShapeView.layer.cornerRadius = 0
            self.ductShapeView.clipsToBounds = true
            self.ductShapeView.layer.borderColor = UIColor.darkGrayColor().CGColor
            self.ductShapeView.layer.borderWidth = 5
            
            // Show elements
            self.ySlider.alpha = 1
            self.yLockButton.alpha = 1
            self.yTextField.alpha = 1
            self.xLockButton.alpha = 1
            self.aspectLabel.alpha = 1
            
            // Alter elements
            self.xTextField.placeholder = "x (mm)"
            self.xSlider.value = (self.xDimension - self.minDim) / (self.maxDim - self.minDim)
            self.ySlider.value = (self.yDimension - self.minDim) / (self.maxDim - self.minDim)
            
            // Change button
            self.ductButton.setTitle("", forState: UIControlState.Normal)
            self.ductButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.ductButton.layer.borderWidth = 2.5
            self.ductButton.layer.borderColor = UIColor.darkGrayColor().CGColor
            self.ductButton.layer.cornerRadius = self.ductButton.frame.size.width/2
            self.ductButton.clipsToBounds = true
            
        }
        else {
            
            // Rectangular duct selected - change to circular
            
            // Unlock the x dim (required for autosize to still work)
            self.xLocked = false
            self.yLocked = false
            
            // Set duct shape
            self.ductShapeView.layer.cornerRadius = self.ductShapeView.frame.size.width/2
            self.ductShapeView.clipsToBounds = true
            self.ductShapeView.layer.borderColor = UIColor.darkGrayColor().CGColor
            self.ductShapeView.layer.borderWidth = 5
            
            // Hide elements
            self.ySlider.alpha = 0
            self.yLockButton.alpha = 0
            self.yTextField.alpha = 0
            self.xLockButton.alpha = 0
            self.aspectLabel.alpha = 0
            
            // Alter elements
            self.xTextField.placeholder = "d (mm)"
            self.xSlider.value = (self.diameter - self.minDim) / (self.maxDim - self.minDim)
            
            // Change button
            self.ductButton.setTitle("", forState: UIControlState.Normal)
            self.ductButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.ductButton.layer.borderWidth = 2.5
            self.ductButton.layer.borderColor = UIColor.darkGrayColor().CGColor
            self.ductButton.layer.cornerRadius = 0
            self.ductButton.clipsToBounds = true
        }
        
        // Update
        self.refresh()
        
    }
    
    
    func autosizeButtonTapped() {
        
        print("autosizeButtonTapped")
        var message:String = String()
        var alertController:UIAlertController = UIAlertController()
        var cancelAction:UIAlertAction = UIAlertAction()
        
        // Make sure there's a flowrate to use
        if (self.flowrateToUse != nil) {
            
            if (self.xLocked && self.yLocked) {
                
                // Both dimensions are locked, can't autosize
                
                // Create the alert controller
                message = "I can't autosize the duct if both dimensions are locked"
                alertController = UIAlertController(title: "Must Unlock Dimension", message: message, preferredStyle: .Alert)
                
                // Create the actions
                cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                    
                    // Any code to be carried our when cancel pressed goes here
                    
                }
                
                // Add the actions
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                
                var aspect:Float? = nil
                
                if (self.autosizeAspect != nil) {
                    // If an aspect has been antered, use it
                    aspect = self.autosizeAspect!
                }
                
                // Check that the velocity has been entered
                if let velocity = self.autosizeVelocity[self.velocitySelector.selectedSegmentIndex] {
                    
                    // Velocity is not nil
                    self.autosize(velocity, aspect: aspect)
                    
                    // Update
                    self.refresh()
                }
                else {
                    
                    // Velocity is nil, the user must have custom selected with no velocity value entered
                    
                    
                    // Create the alert controller
                    message = "I can't autosize the duct if you don't give me a velocity..."
                    alertController = UIAlertController(title: "Must Enter Velocity", message: message, preferredStyle: .Alert)
                    
                    // Create the actions
                    cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.Cancel) {
                        UIAlertAction in
                        NSLog("Cancel Pressed")
                        
                        // Any code to be carried our when cancel pressed goes here
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                
            }
            
        }
        else {
            
            // Flowrate is nil
            
            // Create the alert controller
            message = "I can't autosize the duct if you don't give me a flowrate..."
            alertController = UIAlertController(title: "Must Enter Flowrate", message: message, preferredStyle: .Alert)
            
            // Create the actions
            cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                
                // Any code to be carried our when cancel pressed goes here
                
            }
            
            // Add the actions
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    func lockTapped(sender:UIButton) {
        
        if (sender == self.xLockButton) {
            self.xLocked = !self.xLocked
            print("x dim lockTapped")
        }
        else if (sender == self.yLockButton) {
            self.yLocked = !self.yLocked
            print("y dim lockTapped")
        }
        else {
            print("lockTapped for non x/y button")
        }
        
        self.setAspectRatioAlpha()
        
    }
    
    func setAspectRatioAlpha() {
        
        // Can't size to an aspect ratio if one side is locked or if circular duct selected
        if (self.yLocked || self.xLocked || self.ySlider.alpha != 1) {
            self.autosizeAspect = nil
            self.aspectTextField.text = ""
            self.aspectTextField.userInteractionEnabled = false
            self.aspectTextField.alpha = 0.8
        }
        else {
            self.aspectTextField.userInteractionEnabled = true
            self.aspectTextField.alpha = 1
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
        var index:Int = Int()
        for index = 0; index < self.textFields.count; index++ {
            self.textFields[index].resignFirstResponder()
        }
        self.keyboardHeightLayoutConstraint.constant = 0
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
