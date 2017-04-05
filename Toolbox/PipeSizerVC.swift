//
//  PipeSizerVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 25/03/2017.
//  Copyright © 2017 RichApps. All rights reserved.
//

import UIKit

class PipeSizerVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var massFlowrateTextField: UITextField!
    @IBOutlet weak var loadTextField: UITextField!
    @IBOutlet weak var dtTextField: UITextField!
    @IBOutlet weak var maxPaTextField: UITextField!
    @IBOutlet weak var maxVelTextField: UITextField!
    
    @IBOutlet weak var massFlowrateLabel: UILabel!
    @IBOutlet weak var loadLabel: UILabel!
    @IBOutlet weak var dtLabel: UILabel!
    @IBOutlet weak var maxPdLabel: UILabel!
    @IBOutlet weak var maxVelLabel: UILabel!
    @IBOutlet weak var pdLabel: UILabel!
    @IBOutlet weak var velocityLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var fluidButton: UIButton!
    @IBOutlet weak var applyFluidSelectionButton: UIButton!
    @IBOutlet weak var upSizeButton: UIButton!
    @IBOutlet weak var downSizeButton: UIButton!
    
    @IBOutlet weak var contentView: UIControl!     // main background
    @IBOutlet weak var flowView: UIControl!
    @IBOutlet weak var loadAndDtView: UIControl!
    @IBOutlet weak var centralView: UIControl!
    @IBOutlet weak var maxPaView: UIControl!
    @IBOutlet weak var maxVelView: UIControl!
    @IBOutlet weak var overallPickerView: UIView!
    @IBOutlet weak var pipeView: UIControl!
    @IBOutlet weak var innerPipeView: UIControl!
    
    
    @IBOutlet weak var materialSelector: UISegmentedControl!
    
    @IBOutlet weak var fluidPickerView: UIPickerView!
    
    @IBOutlet weak var maxPaSwitch: UISwitch!
    @IBOutlet weak var maxVelSwitch: UISwitch!
    @IBOutlet var backgroundControls: [UIControl]!
    
    // UI outlets
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var textFields:[UITextField]! // Just for tap background method and setting up
    
    // Fluids that can be selected (via the picker view)
    var fluids:[Calculator.Fluid] = [.LPHW,.CHW,.MWS,.CWS,.HWS,.RWS]
    // set default in viewDidLoad
    var selectedFluid:Calculator.Fluid! {
        // whenever the selected fluid is changed,
        didSet{
            
            // Set the temperature difference to use (and make load nil if no dt)
            self.dt = self.selectedFluid.temperatureDifference
            if (self.dt == nil) {
                self.load = nil
            } else {
                self.updateLoadFromMassFlowrate(mfr: self.massFlowrate)
            }
            
            // Set the default max constraints
            self.maxPd = self.selectedFluid.maxPdDefault
            self.maxVelocity = self.selectedFluid.maxVelocityDefault
            
            // set the fluid button text
            self.fluidButton.setTitle(self.selectedFluid.abreviation, for: UIControlState.normal)
            
            // show/shade the load view if the fluid can have a load
            switch self.selectedFluid.temperatureDifference {
            case nil:
                self.loadAndDtView.alpha = shaded
                self.loadAndDtView.isUserInteractionEnabled = false
            default:
                self.loadAndDtView.alpha = 1
                self.loadAndDtView.isUserInteractionEnabled = true
            }
            
            self.configureFluidButton()
            
            // Change to the default pipe material
            self.selectedMaterial = self.selectedFluid.pipeMaterial
            // Update the selector
            if (self.pipeMaterials.contains(self.selectedMaterial)) {
                self.materialSelector.selectedSegmentIndex = self.pipeMaterials.index(of: self.selectedMaterial)!
            }
        }
    }
    
    // variables to use
    var massFlowrate:Float? = nil
    var load:Float? = nil
    var dt:Float? = nil
    var maxVelocity:Float? = nil
    var maxPd:Float? = nil
    
    // Results
    var availableResults:[(nomDia:Int, pd:Float, v:Float)]? = nil {
        didSet {
            if (self.availableResults == nil || self.availableResults?.count == 0) {
                
                self.currentIndex = nil
                self.resultIndex = nil
                
            }
            
        }
    }
    var resultIndex:Int? = nil
    var currentIndex:Int? = nil {
        didSet {
            // Shade/Show the up/down size buttons
            
            // assume shaded
            self.disableUpSizeButton()
            self.disableDownSizeButton()
            
            if (self.currentIndex != nil) {
                if (self.currentIndex! < self.availableResults!.count - 1) {
                    self.enableUpSizeButton()
                }
                if (self.currentIndex! != 0) {
                    self.enableDownSizeButton()
                }
            }
        }
    }
    

    
    // Alpha to use to shade view
    let shaded:CGFloat = 0.4
    
    // Material
    var pipeMaterials:[Calculator.PipeMaterial] = Calculator.PipeMaterial.all
    // set default in viewDidLoad
    var selectedMaterial:Calculator.PipeMaterial = .Steel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Apply the background tap function to the backgrounds
        for view in self.backgroundControls {
            view.addTarget(self, action: #selector(PipeSizerVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        }
        
        // Set the flowrate view background colours
        self.flowView.backgroundColor = primaryColour
        self.loadAndDtView.backgroundColor = primaryColour
        
        // Set default Fluid
        self.selectedFluid = .LPHW
        
        // Set default max constraints
        self.maxVelSwitch.isOn = false
        self.maxPaSwitch.isOn = false
        
        // Listen for keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(PipeSizerVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
                
        // Hide the picker view
        self.overallPickerView.alpha = 0
        
        // Picker view set up
        self.fluidPickerView.delegate = self
        self.fluidPickerView.dataSource = self
        
        // Buttons for picker view
        self.applyFluidSelectionButton.addTarget(self, action: #selector(PipeSizerVC.togglePickerView), for: .touchUpInside)
        self.fluidButton.addTarget(self, action: #selector(PipeSizerVC.togglePickerView), for: .touchUpInside)
        
        self.applyFluidSelectionButton.layer.cornerRadius = 2.5
        
        self.fluidButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.fluidButton.layer.borderWidth = 2.5
        self.fluidButton.layer.cornerRadius = 8
        self.fluidButton.clipsToBounds = true
        self.fluidButton.tintColor = UIColor.white
        self.fluidButton.layer.backgroundColor = lphwColour.cgColor
        self.fluidButton.layer.borderColor = UIColor.darkGray.cgColor
        
        // Up/down size buttons
        self.upSizeButton.addTarget(self, action: #selector(PipeSizerVC.upSize), for: .touchUpInside)
        self.downSizeButton.addTarget(self, action: #selector(PipeSizerVC.downSize), for: .touchUpInside)
        
        // Autosize switches
        self.maxPaSwitch.addTarget(self, action: #selector(PipeSizerVC.refresh), for: .valueChanged)
        self.maxVelSwitch.addTarget(self, action: #selector(PipeSizerVC.refresh), for: .valueChanged)
        
        // Set up the text fields
        for textField in self.textFields {
            self.setupTextFieldInputAccessoryView(textField)
            textField.addTarget(self, action: #selector(PipeSizerVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
            textField.clearsOnBeginEditing = true
        }
        
        // Set up material selector 
        // Add a segment for each material
        self.materialSelector.removeAllSegments()
        for index:Int in 0..<self.pipeMaterials.count {
            let material:Calculator.PipeMaterial = self.pipeMaterials[index]
            self.materialSelector.insertSegment(withTitle: material.material, at: index, animated: false)
        }
        // Add the update material action
        self.materialSelector.addTarget(self, action: #selector(PipeSizerVC.changeMaterial), for: UIControlEvents.valueChanged)
        // Set the currently selected index
        if (self.pipeMaterials.contains(self.selectedMaterial)) {
            self.materialSelector.selectedSegmentIndex = self.pipeMaterials.index(of: self.selectedMaterial)!
        }
        
        // Default constraints on if provided
        if (self.maxPd != nil) {
            self.maxPaSwitch.setOn(true, animated: false)
        }
        if (self.maxVelocity != nil) {
            self.maxVelSwitch.setOn(true, animated: false)
        }
        
        self.refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func layoutPipeView() {
        
        self.pipeView.layer.cornerRadius = self.pipeView.frame.size.width/2
        self.pipeView.clipsToBounds = true
        self.pipeView.layer.borderWidth = 2
        self.pipeView.layer.borderColor = UIColor.darkGray.cgColor
        
        self.innerPipeView.layer.cornerRadius = self.innerPipeView.frame.size.width/2
        self.innerPipeView.clipsToBounds = true
        self.innerPipeView.layer.borderWidth = 2
        self.innerPipeView.layer.borderColor = UIColor.darkGray.cgColor
        
        // Background colours (outter will be material colour and inner will be white)
        self.pipeView.backgroundColor = self.selectedMaterial.colour
        self.innerPipeView.backgroundColor = UIColor.white
        
    }
    
    func configureFluidButton() {
        
        self.fluidButton.setTitle(self.selectedFluid.abreviation, for: UIControlState.normal)
        self.fluidButton.tintColor = UIColor.white
        self.fluidButton.layer.backgroundColor = self.selectedFluid.colour.cgColor
        self.fluidButton.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    
    func refresh() {
        print("refresh")
        
        // Update the pipe colour if required
        self.layoutPipeView()
        
        // refresh the fluid button
        self.configureFluidButton()
        
        // Reset the result texts
        self.sizeLabel.text = "--\nmm"
        self.pdLabel.text = "--\nPa/m"
        self.velocityLabel.text = "--\nm/s"
        
        // Set textfield text fields
        if let value = self.massFlowrate {
            self.massFlowrateTextField.text = String(format: "%.2f", value)
        } else {
            self.massFlowrateTextField.text = ""
        }
        
        if let value = self.load {
            self.loadTextField.text = String(format: "%.2f", value)
        } else {
            self.loadTextField.text = ""
        }
        
        if let value = self.dt {
            self.dtTextField.text = String(format: "%.0f", value)
        } else {
            self.dtTextField.text = ""
        }
        
        if let value = self.maxPd {
            self.maxPaTextField.text = String(format: "%.0f", value)
        } else {
            self.maxPaTextField.text = ""
        }
        
        if let value = self.maxVelocity {
            self.maxVelTextField.text = String(format: "%.2f", value)
        } else {
            self.maxVelTextField.text = ""
        }

        
        // Get the available results (all pipe sizes)
        if let actualMfr = self.massFlowrate {
            self.availableResults = calculator.resultsForPipe(massFlowrate: actualMfr, fluid: self.selectedFluid, material: self.selectedMaterial)
        } else {
            self.availableResults = nil
        }
        
        
        // if there are available results, check if we need a specific one
        if let actualResults = self.availableResults {
            
            
            // Check if we need to autosize
            self.resultIndex = nil
            if (self.maxPaSwitch.isOn || self.maxVelSwitch.isOn) {
                
                if let actualMfr = self.massFlowrate {
                    
                    // Even if there is a maxPa and/or maxVel, only apply them if the switch is enabled
                    let maxVelocityToUse:Float? = self.maxVelSwitch.isOn ? self.maxVelocity: nil
                    let maxPdToUse:Float? = self.maxPaSwitch.isOn ? self.maxPd: nil
                    
                    // Get the specific result based on the provided constraints
                    let specificResult = calculator.sizePipe(massFlowrate: actualMfr, material: self.selectedMaterial, fluid: self.selectedFluid, maxPd: maxPdToUse, maxVelocity: maxVelocityToUse)
                    
                    // Check where it is within the available results and set the index
                    for currentIndex:Int in 0..<actualResults.count {
                        if (actualResults[currentIndex].nomDia == specificResult?.nomDia) {
                            self.resultIndex = currentIndex
                            break
                        }
                    }
                }
            }
            
            // Decide what index to display
            var indexToShow:Int? = nil
            
            // Either a specific result, or a last viewed
            if (self.resultIndex != nil) {
                indexToShow = self.resultIndex
            } else if (self.currentIndex != nil) {
                indexToShow = self.currentIndex
            }
            
            // Check if we need to show results
            if let index = indexToShow {
            
                // Check if the index we want to show is available
                if (index < actualResults.count) {
                    
                    // Update the labels
                    self.sizeLabel.text = String(format: "%i\nmm", actualResults[index].nomDia)
                    self.pdLabel.text = String(format: "%.2f\nPa/m", actualResults[index].pd)
                    self.velocityLabel.text = String(format: "%.2f\nm/s", actualResults[index].v)
                    
                    // Remember the index
                    self.currentIndex = index
                    
                } else {
                    
                    // If the last current index exceeds the maximum index
                    // If the pipe material changed and the new material has less sizes available than the last
                    // Just use the last index
                    
                    // Update the labels
                    self.sizeLabel.text = String(format: "%i\nmm", actualResults.last!.nomDia)
                    self.pdLabel.text = String(format: "%.2f\nPa/m", actualResults.last!.pd)
                    self.velocityLabel.text = String(format: "%.2f\nm/s", actualResults.last!.v)
                    
                    // Remember the index
                    self.currentIndex = actualResults.count - 1
                }
                
                
                
            } else if (actualResults.count > 0) {
                
                    // Default to the first index if it's available
                    
                    self.sizeLabel.text = String(format: "%i\nmm", actualResults[0].nomDia)
                    self.pdLabel.text = String(format: "%.2f\nPa/m", actualResults[0].pd)
                    self.velocityLabel.text = String(format: "%.2f\nm/s", actualResults[0].v)
                    
                    self.currentIndex = 0
                
            }
            
        }
        
    }
    
    
    // MARK: IB Actions
    
    func togglePickerView() {
        
        
        // Show/hide the picker view
        if (self.overallPickerView.alpha == 0) {
            print("togglePickerView - show")
            // show it
            self.overallPickerView.alpha = 1
            // Set the correct selection
            if let indexOfFluid = self.fluids.index(of: self.selectedFluid) {
                self.fluidPickerView.selectRow(indexOfFluid, inComponent: 0, animated: false)
            }
        } else {
            print("togglePickerView - hide")
            // hide it
            self.overallPickerView.alpha = 0
            // recalculate (selected fluid may have been changed)
            self.refresh()
        }
        
    }
    
    func upSize() {
        
        print("upSize")
        self.disableAutoSize()
        
        // Show the size above that currently shown, if available
        // Note, current index is automatically nil if available results are nil (in didSet), so safe to unwrap
        if (self.currentIndex != nil) {
            let nextIndex:Int = self.currentIndex! + 1
            if (nextIndex < self.availableResults!.count) {
                self.currentIndex = nextIndex
                self.refresh()
            }
        }
        
    }
    
    func downSize() {
        
        print("downSize")
        self.disableAutoSize()
        
        // Show the size above that currently shown, if available
        // Note, current index is automatically nil if available results are nil (in didSet), so safe to unwrap
        if (self.currentIndex != nil) {
            let prevIndex:Int = self.currentIndex! - 1
            if (prevIndex >= 0 && prevIndex < self.availableResults!.count) {
                self.currentIndex = prevIndex
                self.refresh()
            }
        }
        
    }
    
    func disableAutoSize() {
        self.maxPaSwitch.setOn(false, animated: true)
        self.maxVelSwitch.setOn(false, animated: true)
    }
    
    func disableUpSizeButton() {
        self.upSizeButton.alpha = shaded
        self.upSizeButton.isUserInteractionEnabled = false
    }
    func disableDownSizeButton() {
        self.downSizeButton.alpha = shaded
        self.downSizeButton.isUserInteractionEnabled = false
    }
    
    func enableUpSizeButton() {
        self.upSizeButton.alpha = 1
        self.upSizeButton.isUserInteractionEnabled = true
    }
    func enableDownSizeButton() {
        self.downSizeButton.alpha = 1
        self.downSizeButton.isUserInteractionEnabled = true
    }
    
    // MARK: Update variables
    
    func updateLoadFromMassFlowrate(mfr:Float?) {
        
        print("updateLoadFromMassFlowrate")
        
        self.load = nil
        
        // If we have a MFR and a dt, get the load
        if let actualMfr = mfr {
            if let actualDt = self.dt {
                self.load = calculator.load(massFlowrate:actualMfr, specificHeatCapacity:self.selectedFluid.specificHeatCapacity, temperatureDifference:actualDt)
            }
        }
    }
    
    func updateMassFlowrateFromLoad(load:Float?, dt:Float?) {
        print("updateMassFlowrateFromLoad")
        
        self.massFlowrate = nil
        
        // If we have a MFR and a dt, get the load
        if let actualLoad = load {
            if let actualDt = dt {
                self.massFlowrate = calculator.massFlowrate(load: actualLoad, specificHeatCapacity: self.selectedFluid.specificHeatCapacity, temperatureDifference: actualDt)
            }
        }
    }
    
    // NARK: Material Selector
    
    func changeMaterial() {
        print("changeMaterial")
        if (self.pipeMaterials.count >= self.materialSelector.numberOfSegments) {
            self.selectedMaterial = self.pipeMaterials[self.materialSelector.selectedSegmentIndex]
            self.refresh()
        }
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
            case self.massFlowrateTextField:
                self.massFlowrate = newValue
                self.updateLoadFromMassFlowrate(mfr: newValue)
            case self.loadTextField:
                self.load = newValue
                self.updateMassFlowrateFromLoad(load: self.load, dt:self.dt)
            case self.dtTextField:
                self.dt = newValue
                self.updateMassFlowrateFromLoad(load: self.load, dt:self.dt)
            case self.maxPaTextField:
                self.maxPd = newValue
                self.maxPaSwitch.setOn(self.maxPd != nil, animated: true)
            case self.maxVelTextField:
                self.maxVelocity = newValue
                self.maxVelSwitch.setOn(self.maxVelocity != nil, animated: true)
            default:
                print("Could not find matching Text Field to update value")
            }
                        
        }
        
        self.refresh()
        
        
    }

    
    // MARK: Picker View
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fluids.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fluids[row].description
    }
    
    // What to do when an item is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        
        if (row < self.fluids.count) {
            // change the fluid
            self.selectedFluid = self.fluids[row]
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
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(PipeSizerVC.applyButtonAction))
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



}
