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
    @IBOutlet weak var freeAreaTextField: UITextField!
    
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
            ySlider.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
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
    let increment:Float = calculator.ductDimensionIncrement * 1000
    
    let shaded:CGFloat = 0.3
    
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
    var aspect:Float = Float()          // -
    
    var freeArea:Float = Float()        // -   (0 to 1)
    {
        didSet{
            
            // Max is 1, Min is 0
            if self.freeArea > 1 {
                self.freeArea = 1
            } else if self.freeArea < 0 {
                self.freeArea = 0
            }
            
        }
    }
    
    
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
    
    // Calculator's results for current configuration
    var resultsRect:(length:Float, width:Float, aspect:Float, pd:Float, v:Float)? = nil
    var resultsCirc:(diameter:Float, pd:Float, v:Float)? = nil
    

    // MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Listen for keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(DuctSizerVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Initally set to flowrate view
        self.flowrateView.alpha = 1
        self.achView.alpha = 1
        
        let topViews:[UIView] = [self.flowrateView, self.achView]
        for view in topViews {
            view.layer.borderColor = UIColor.darkGray.cgColor
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
            textField.addTarget(self, action: #selector(DuctSizerVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
        }
        
        // Apply the background tap function to the backgrounds
        for view in self.backGroundControlViews {
            view.addTarget(self, action: #selector(DuctSizerVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        }
        
        // Set up the sliders
        let sliders:[UISlider] = [self.xSlider, self.ySlider]
        for slider in sliders {
            slider.addTarget(self, action: #selector(DuctSizerVC.sliderDidChange(_:)), for: UIControlEvents.valueChanged)
            slider.addTarget(self, action: #selector(DuctSizerVC.sliderTouched(_:)), for: UIControlEvents.touchDown)
            slider.addTarget(self, action: #selector(DuctSizerVC.sliderReleased(_:)), for: UIControlEvents.touchUpInside)
            slider.addTarget(self, action: #selector(DuctSizerVC.sliderReleased(_:)), for: UIControlEvents.touchUpOutside)
        }
        
        // Set up the velocity selector
        self.velocitySelector.addTarget(self, action: #selector(DuctSizerVC.velocitySelectorDidChange(_:)), for: UIControlEvents.valueChanged)
        
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
            
            view.backgroundColor = primaryColour
            
        }
        
        // Set the initial values
        self.setInitialValues()
        
        // Set up is finished, refresh the view
        self.refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Refresh incase we're coming from settings and the properties changed
        self.refresh()
        self.backgroundTapped(self)
        
        // Google Analytics
        let name = "Duct Sizer"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
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
        
        self.freeArea = 1
        
    }
    
    func setUpButtons() {
        
        // Add methods
        self.ductButton.addTarget(self, action: #selector(DuctSizerVC.ductButtonTapped), for: UIControlEvents.touchUpInside)
        self.autoSizeButton.addTarget(self, action: #selector(DuctSizerVC.autosizeButtonTapped), for: UIControlEvents.touchUpInside)
        self.xLockButton.addTarget(self, action: #selector(DuctSizerVC.lockTapped(_:)), for: UIControlEvents.touchUpInside)
        self.yLockButton.addTarget(self, action: #selector(DuctSizerVC.lockTapped(_:)), for: UIControlEvents.touchUpInside)
        
        // Change autosize appearance
        self.autoSizeButton.setTitle("Autosize", for: UIControlState())
        self.autoSizeButton.layer.backgroundColor = UIColor.white.cgColor
        self.autoSizeButton.layer.borderWidth = 2.5
        self.autoSizeButton.layer.borderColor = UIColor.darkGray.cgColor
        self.autoSizeButton.layer.cornerRadius = self.ductButton.frame.size.height/3
        self.autoSizeButton.clipsToBounds = true
        
        // Get rid of lock button titles
        self.xLockButton.setTitle("", for: UIControlState())
        self.yLockButton.setTitle("", for: UIControlState())
        
    }
    
    func lockChanged(_ sender:UIButton) {
        
        let greenColour:UIColor = UIColor(red: 100/255, green: 180/255, blue: 0/255, alpha: 1)
        let redColour:UIColor = UIColor.red
        
        // Called whenever xLocked or yLocked is changed
        
        if (sender == self.xLockButton) {
            
            if (self.xLocked) {
                self.xLockButton.setImage(UIImage(named: "Locked"), for: UIControlState())
                self.xLockButton.tintColor = redColour
                self.xSlider.isUserInteractionEnabled = false
                self.xSlider.alpha = shaded
                //if (self.yLocked) {self.yLocked = false}    // Only 1 side locked at a time
            }
            else {
                self.xLockButton.setImage(UIImage(named: "Unlocked"), for: UIControlState())
                self.xLockButton.tintColor = greenColour
                self.xSlider.isUserInteractionEnabled = true
                self.xSlider.alpha = 1
            }
            
        }
        else if (sender == self.yLockButton) {
            
            if (self.yLocked) {
                self.yLockButton.setImage(UIImage(named: "Locked"), for: UIControlState())
                self.yLockButton.tintColor = redColour
                self.ySlider.isUserInteractionEnabled = false
                self.ySlider.alpha = shaded
                //if (self.xLocked) {self.xLocked = false}    // Only 1 side locked at a time
            }
            else {
                self.yLockButton.setImage(UIImage(named: "Unlocked"), for: UIControlState())
                self.yLockButton.tintColor = greenColour
                self.ySlider.isUserInteractionEnabled = true
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
        
        // Check what's displayed
        var resultVelocity:Float? = nil
        var resultPd:Float? = nil
        
        if (self.ySlider.alpha != 0) {
            // Rectangular
            if let result = self.resultsRect {
                resultVelocity = result.v
                resultPd = result.pd
            }
        }
        else {
            // Circular
            if let result = self.resultsCirc {
                resultVelocity = result.v
                resultPd = result.pd
            }
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
        self.calculateAspectRatio()
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
        
        
        // FREE AREA
        
        // If using a free area, the pd calc won't work correctly (it still assumes full diameter), so hide it.
        // Also, change the text of the textfield accordingly
        if self.freeArea == 1 {
            self.pdLabel.alpha = 1
            self.freeAreaTextField.text = ""
        } else {
            self.pdLabel.alpha = 0
            self.freeAreaTextField.text = String(format: "%.0f%@", self.freeArea * 100, "%")
        }
        
    }
    
    
    // MARK: - Calculations
    
    func calculate() {
        print("calculate")
        
        if let flowrate = self.flowrateToUse {
            
            // Dimensions
            let x:Float = self.xDimension / 1000    // m
            let y:Float = self.yDimension / 1000    // m
            let d:Float = self.diameter / 1000      // m
            
            self.resultsRect = calculator.resultsForDuct(length: x, width: y, freeArea: self.freeArea, volumeFlowrate: flowrate, duct: .Rect, maxPd: nil, maxVelocity: nil, aspect: nil)
            self.resultsCirc = calculator.resultsForDuct(diameter: d, freeArea: self.freeArea, volumeFlowrate: flowrate, duct: .Circ, maxPd: nil, maxVelocity: nil)
            
        }
        
    }
    
    func calculateAspectRatio() {
        print("calculateAspectRatio")
        
        if (self.xDimension >= self.yDimension) {
            self.aspect = self.xDimension/self.yDimension
        }
        else {
            self.aspect = self.yDimension/self.xDimension
        }
        
    }
    
    func autosize(_ velocity:Float, aspect:Float?) {
        print("autosize")
        
        // Have already checked that both dimensions are not locked
        // Also, whenever circ duct is selected, both Dims are unlocked
        
        // length or width may be specified (both not both), diameter can't be specified for autosize
        var x:Float? = nil
        var y:Float? = nil
        
        if (self.xLocked) {
            x = self.xDimension / 1000
        } else if (self.yLocked) {
            y = self.yDimension / 1000
        }
        
        // Calculate the results
        
        if let flowrate = self.flowrateToUse {
            
            self.resultsRect = calculator.resultsForDuct(length: x, width: y, freeArea: self.freeArea, volumeFlowrate: flowrate, duct: .Rect, maxPd: nil, maxVelocity: velocity, aspect: aspect)
            self.resultsCirc = calculator.resultsForDuct(diameter: nil, freeArea: self.freeArea, volumeFlowrate: flowrate, duct: .Circ, maxPd: nil, maxVelocity: velocity)
            
            if let result = self.resultsRect {
                self.xDimension = result.length * 1000
                self.yDimension = result.width * 1000
            }
            
            if let result = self.resultsCirc {
                self.diameter = result.diameter * 1000
            }
            
        }
        
        
        // Check what's displayed
        // X either represents diameter or length
        if (self.ySlider.alpha != 0) {
            self.xSlider.value = (self.xDimension - self.minDim) / (self.maxDim - self.minDim)
        }
        else {
            self.xSlider.value = (self.diameter - self.minDim) / (self.maxDim - self.minDim)
        }
        
        // Y always represents width (and isn't shown when diameter is circular is selected)
        self.ySlider.value = (self.yDimension - self.minDim) / (self.maxDim - self.minDim)
        
        self.refresh()
        
    }
    
    
    // MARK: - TextField Functions
    
    func textFieldEditingDidEnd(_ sender:UITextField) {
        
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
            case self.freeAreaTextField:
                // Convert the percentage to a decimal and assign to freeArea
                // Note that the didSet function checks for max and min
                
                if (sender.text!.floatValue == 0) {
                    self.freeArea = 1
                } else {
                    self.freeArea = sender.text!.floatValue / 100
                }
                
            default:
                print("Could not find matching Text Field to update value")
            }
            
        }
        
        self.refresh()
        
    }
    
    func updateFlowrate(_ sender:UITextField) {
        print("updateFlowrate")
        
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
    
    func sliderDidChange(_ sender:UISlider) {
        print("sliderDidChange")
        
        // Get value
        var newDim:Float = (self.maxDim - self.minDim) * sender.value + self.minDim
        
        let remainder:Float = newDim.truncatingRemainder(dividingBy: self.increment)
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
    
    func sliderTouched(_ sender:UISlider) {
        
        if (sender == self.xSlider) {
            print("xSlider touched")
            self.xHighlighterView.alpha = 1
        }
        else if (sender == self.ySlider) {
            print("ySlider touched")
            self.yHighlighterView.alpha = 1
        }
        
    }
    
    func sliderReleased(_ sender:UISlider) {
        
        if (sender == self.xSlider) {
            print("xSlider released")
            self.xHighlighterView.alpha = 0
        }
        else if (sender == self.ySlider) {
            print("ySlider released")
            self.yHighlighterView.alpha = 0
        }
        
    }
    
    func velocitySelectorDidChange(_ sender:UISegmentedControl) {
        print("velocitySelectorDidChange")
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            self.velocityTextField.isUserInteractionEnabled = true
            self.velocityTextField.alpha = 1
        default:
            self.velocityTextField.isUserInteractionEnabled = false
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
            self.ductShapeView.layer.borderColor = UIColor.darkGray.cgColor
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
            self.ductButton.setTitle("", for: UIControlState())
            self.ductButton.layer.backgroundColor = UIColor.white.cgColor
            self.ductButton.layer.borderWidth = 2.5
            self.ductButton.layer.borderColor = UIColor.darkGray.cgColor
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
            self.ductShapeView.layer.borderColor = UIColor.darkGray.cgColor
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
            self.ductButton.setTitle("", for: UIControlState())
            self.ductButton.layer.backgroundColor = UIColor.white.cgColor
            self.ductButton.layer.borderWidth = 2.5
            self.ductButton.layer.borderColor = UIColor.darkGray.cgColor
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
                alertController = UIAlertController(title: "Must Unlock Dimension", message: message, preferredStyle: .alert)
                
                // Create the actions
                cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                    NSLog("Cancel Pressed")
                    
                    // Any code to be carried our when cancel pressed goes here
                    
                }
                
                // Add the actions
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                
                var aspect:Float? = nil
                
                if (self.autosizeAspect != nil) {
                    // If an aspect has been entered, use it
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
                    alertController = UIAlertController(title: "Must Enter Velocity", message: message, preferredStyle: .alert)
                    
                    // Create the actions
                    cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        NSLog("Cancel Pressed")
                        
                        // Any code to be carried our when cancel pressed goes here
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
            
        }
        else {
            
            // Flowrate is nil
            
            // Create the alert controller
            message = "I can't autosize the duct if you don't give me a flowrate..."
            alertController = UIAlertController(title: "Must Enter Flowrate", message: message, preferredStyle: .alert)
            
            // Create the actions
            cancelAction = UIAlertAction(title: "Whoops", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
                
                // Any code to be carried our when cancel pressed goes here
                
            }
            
            // Add the actions
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    func lockTapped(_ sender:UIButton) {
        print("lockTapped")
        
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
        print("setAspectRatioAlpha")
        
        // Can't size to an aspect ratio if one side is locked or if circular duct selected
        if (self.yLocked || self.xLocked || self.ySlider.alpha != 1) {
            self.autosizeAspect = nil
            self.aspectTextField.text = ""
            self.aspectTextField.isUserInteractionEnabled = false
            self.aspectTextField.alpha = 0.8
        }
        else {
            self.aspectTextField.isUserInteractionEnabled = true
            self.aspectTextField.alpha = 1
        }
    }
    
    
    // MARK: - Keyboard Related
    
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
        print("backgroundTapped")        
        for index:Int in 0..<self.textFields.count {
            self.textFields[index].resignFirstResponder()
        }
        self.keyboardHeightLayoutConstraint.constant = 0
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(DuctSizerVC.applyButtonAction))
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
        print("applyButtonAction")
        self.backgroundTapped(self)
    }


}
