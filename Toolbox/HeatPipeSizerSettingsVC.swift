//
//  HeatPipeSizerSettingsVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 03/08/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class HeatPipeSizerSettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var selector: UISegmentedControl!
    
    // Method View
    @IBOutlet weak var methodView: UIControl!
    @IBOutlet weak var methodTableView: UITableView!
    
    let methodSectionHeadings:[String] = ["Overview","Set Up","Configuring Loads"]
    
    
    // Variable View
    @IBOutlet weak var variableView: UIControl!
    @IBOutlet weak var variableTableView: UITableView!
    
    let numberOfRowsPerFluid:Int = 5
    
    let variableFluids:[Calculator.Fluid] = [.LPHW, .CHW]       // NB: The fluids used must have a temperature difference property!! (it can't be nil)
    let variableCellIdentifier:String = "variableCell"
    let variableButtonCellIdentifier:String = "buttonCell"
    let variableSelectorCellIdentifier:String = "selectorCell"
    
    // Array of variable textfields just so they can be dismissed
    var textFields:[DemandUnitTF] = [DemandUnitTF]()
    
    // Keyboard height
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    
    // MARK: System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PipeSizerSettingsVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.selector.addTarget(self, action: #selector(PipeSizerSettingsVC.selectorDidChange), for: UIControlEvents.valueChanged)
        self.selector.tintColor = UIColor.darkGray
        self.selector.selectedSegmentIndex = 0
        
        // Apply the row height
        self.methodTableView.rowHeight = UITableViewAutomaticDimension;
        self.methodTableView.estimatedRowHeight = 64.0;
        
        self.variableTableView.rowHeight = UITableViewAutomaticDimension;
        self.variableTableView.estimatedRowHeight = 64.0;
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Also includes refresh method
        self.selectorDidChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        // Prevents keyboard issues
        self.backgroundTapped(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Google Analytics
        let name = "Multiple Load Pipe Sizer Settings"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UI
    
    func refresh() {
        print("View refreshed")
        self.methodTableView.reloadData()
        self.variableTableView.reloadData()
        
    }
    
    func selectorDidChange() {
        print("selectorDidChange")
        
        switch self.selector.selectedSegmentIndex {
            
        case 1:
            self.methodView.alpha = 0
            self.variableView.alpha = 1
            self.variableTableView.reloadData()
        default:
            self.methodView.alpha = 1
            self.variableView.alpha = 0
            self.methodTableView.reloadData()
        }
        
    }
    
    
    // MARK: - Reset Variables
    
    func resetFluid(button:ButtonWithRow) {
        // The button tag corresponds to the fluid index
        if button.row < self.variableFluids.count {
            calculator.resetDefaultFluidProperties(fluid: self.variableFluids[button.row])
            self.variableTableView.reloadData()
        }
        
    }
    
    func resetPipeMaterials() {
        // This will reset the k value for all materials
        calculator.resetDefaultPipeProperties()
        self.variableTableView.reloadData()
    }
    
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // print("numberOfRowsInSection")
        
        switch tableView {
            
        case self.methodTableView:
            
            return 1
            
        case self.variableTableView:
            
            switch section {
                
            case self.variableFluids.count - 1 + 1:
                // One row for each pipe material available (for its k-value)
                // plus one for reset defaults
                return Calculator.PipeMaterial.all.count + 1
                
            default:
                return self.numberOfRowsPerFluid
                
            }
            
            
        default:
            print("Error: This should not occur")
            return 0
        }
        
        
    }
    
    // Determine Number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        
        switch tableView {
            
        case self.methodTableView:
            return self.methodSectionHeadings.count
            
        case self.variableTableView:
            // All fluids plus pipe materials
            return self.variableFluids.count + 1
            
        default:
            print("Error: This should not occur")
            return 0
        }
        
    }
    
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        switch tableView {
            
        case self.methodTableView, self.variableTableView:
            
            returnHeader(view, colourOption: 4)
            
        default:
            
            print("")
            
        }
        
    }
    
    // Make sure the header size is what we want
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderSizae
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch tableView {
            
        case self.methodTableView:
            
            return self.methodSectionHeadings[section]
            
        case self.variableTableView:
            
            switch section {
                
            case self.variableFluids.count - 1 + 1:
                // If it's the section after all the fluids
                return "Pipe Materials"
            default:
                // if it's a fluid section
                return self.variableFluids[section].description
            }
            
            
        default: // Method
            
            return ""
            
        }
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // print("cellForRowAtIndexPath \(indexPath.section) - \(indexPath.row)")
        
        var cell:UITableViewCell? = nil
        
        switch tableView {
            
        case self.variableTableView:
            
            switch indexPath.section {
                
            case self.variableFluids.count - 1 + 1:
                
                // the section after all of the fluids for the pipe materials
                
                switch indexPath.row {
                    
                case Calculator.PipeMaterial.all.count - 1 + 1:
                    
                    // Reset Defaults
                    cell = tableView.dequeueReusableCell(withIdentifier: self.variableButtonCellIdentifier) as UITableViewCell?
                    if (cell == nil) {
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.variableButtonCellIdentifier)
                    }
                    
                    let button:ButtonWithRow = cell!.viewWithTag(20) as! ButtonWithRow
                    let contentView:UIControl = cell!.viewWithTag(2) as! UIControl
                    
                    // Set background tap
                    self.addBackgroundTap(contentView)
                    
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    button.layer.borderWidth = 1.5
                    button.layer.cornerRadius = 5
                    button.layer.backgroundColor = UIColor.white.cgColor
                    button.setTitle("    Reset Defaults    ", for: UIControlState())
                    button.tintColor = UIColor.darkGray
                    // Don't need to set the section for this as the target function doesn't need to know what called it
                    // button.row = indexPath.section
                    button.addTarget(self, action: #selector(HeatPipeSizerSettingsVC.resetPipeMaterials), for: UIControlEvents.touchUpInside)
                    
                default:
                    
                    // Text field edits
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: self.variableCellIdentifier) as UITableViewCell?
                    if (cell == nil) {
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.variableCellIdentifier)
                    }
                    
                    // Grab the components
                    let nameLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                    let descLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                    let textField:DemandUnitTF = cell!.viewWithTag(3) as! DemandUnitTF
                    let contentView:UIControl = cell!.viewWithTag(4) as! UIControl
                    
                    // Set background tap
                    self.addBackgroundTap(contentView)
                    
                    // Set up the textfield
                    // Note: we use a demandUnitTextField just so we can track the indexPath (so we can figure out which property to change when it's edited)
                    textField.minimumFontSize = 5
                    textField.adjustsFontSizeToFitWidth = true
                    textField.addTarget(self, action: #selector(HeatPipeSizerSettingsVC.textFieldEditingDidEnd(variableTextField:)), for: UIControlEvents.editingDidEnd)
                    textField.indexPath = indexPath
                    textField.row = indexPath.row
                    textField.column = indexPath.section
                    self.setupTextFieldInputAccessoryView(textField)
                    self.textFields.append(textField)
                    
                    // The property values to be displayed in the first four rows
                    let material:Calculator.PipeMaterial = Calculator.PipeMaterial.all[indexPath.row]
                    
                    // Set the text field texts
                    if (material.kValue <= 0.0009) {
                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = NumberFormatter.Style.scientific
                        formatter.usesSignificantDigits = false
                        formatter.maximumSignificantDigits = 3
                        formatter.minimumSignificantDigits = 3
                        textField.text = formatter.string(from: NSNumber(value: material.kValue))
                    }
                    else {
                        textField.text = String(format: "%.4f", material.kValue)
                    }
                    
                    nameLabel.text = ""
                    descLabel.text = "\(material.material) k value\n(/mm)"
                    
                }
                
            default:
                
                // NB: Fluids must be before other sections
                
                // Fluids
                let fluid:Calculator.Fluid = self.variableFluids[indexPath.section]
                
                // Rows:
                
                // Density
                // Viscosity
                // Temperature Difference
                // Max Pd
                // Reset Defaults
                
                switch indexPath.row {
                    
                case 4:
                    
                    // Reset Defaults
                    cell = tableView.dequeueReusableCell(withIdentifier: self.variableButtonCellIdentifier) as UITableViewCell?
                    if (cell == nil) {
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.variableButtonCellIdentifier)
                    }
                    
                    let button:ButtonWithRow = cell!.viewWithTag(20) as! ButtonWithRow
                    let contentView:UIControl = cell!.viewWithTag(2) as! UIControl
                    
                    // Set background tap
                    self.addBackgroundTap(contentView)
                    
                    button.layer.borderColor = UIColor.darkGray.cgColor
                    button.layer.borderWidth = 1.5
                    button.layer.cornerRadius = 5
                    button.layer.backgroundColor = UIColor.white.cgColor
                    button.setTitle("    Reset Defaults    ", for: UIControlState())
                    button.tintColor = UIColor.darkGray
                    // Set the row of the button to the section so we know what fluid it represents when its tapped
                    button.row = indexPath.section
                    button.addTarget(self, action: #selector(HeatPipeSizerSettingsVC.resetFluid(button:)), for: UIControlEvents.touchUpInside)
                    
                default:
                    
                    // Text field edits
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: self.variableCellIdentifier) as UITableViewCell?
                    if (cell == nil) {
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.variableCellIdentifier)
                    }
                    
                    // Grab the components
                    let nameLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                    let descLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                    let textField:DemandUnitTF = cell!.viewWithTag(3) as! DemandUnitTF
                    let contentView:UIControl = cell!.viewWithTag(4) as! UIControl
                    
                    // Set background tap
                    self.addBackgroundTap(contentView)
                    
                    // Set up the textfield
                    // Note: we use a demandUnitTextField just so we can track the indexPath (sow we can figure out which property to change when it's edited)
                    textField.minimumFontSize = 5
                    textField.adjustsFontSizeToFitWidth = true
                    textField.addTarget(self, action: #selector(HeatPipeSizerSettingsVC.textFieldEditingDidEnd(variableTextField:)), for: UIControlEvents.editingDidEnd)
                    textField.indexPath = indexPath
                    textField.row = indexPath.row
                    textField.column = indexPath.section
                    self.setupTextFieldInputAccessoryView(textField)
                    self.textFields.append(textField)
                    
                    // The property values to be displayed in the first four rows
                    let properties:[Float] = [fluid.density, fluid.visocity, fluid.temperatureDifference!, fluid.maxPdDefault]
                    
                    // Set the text field texts
                    if (properties[indexPath.row] <= 0.009) {
                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = NumberFormatter.Style.scientific
                        formatter.usesSignificantDigits = false
                        formatter.maximumSignificantDigits = 3
                        formatter.minimumSignificantDigits = 3
                        textField.text = formatter.string(from: NSNumber(value: properties[indexPath.row]))
                    }
                    else {
                        textField.text = String(format: "%.2f", properties[indexPath.row])
                    }
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = ""
                        descLabel.text = "Density\n(kg/m3)"
                    case 1:
                        nameLabel.text = ""
                        descLabel.text = "Dynamic viscosity\n(kg/ms)"
                    case 2:
                        nameLabel.text = ""
                        descLabel.text = "F&R temperature difference\n(K)"
                    case 3:
                        nameLabel.text = ""
                        descLabel.text = "Default maximum pressure drop\n(Pa/m)"
                    default:
                        print("This row should not be here")
                    }
                    
                }
                
                
            }
            
            
            
        case self.methodTableView:
            
            switch indexPath.section {
                
            case 0: // Overview
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "This calculation allows you to size LPHW / CHW pipework that serves multiple loads.\n\nThe pipes are sized according to the maximum pressure drop selected."
                
                
            case 1: // Set Up
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "A header section is provided at the top of the screen. The maximum pressure drop is set using the textfield. The two buttons are used to cycle between the available fluids (LPHW or CHW) and the available pipework materials.\n\nThe header section also shows the resulting flowrate, pipe size and pressure drop for the combined loads (which are configured in the lower section)."
                
            case 2: // Configuring Loads
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "There are 6 optional load types that can be configured.\n\nTo configure a load type, you must first enter the load or flowrate required. If the load is input, the flowrate will be overwritten and vice versa. Next, the quantity of this load type must be set using the textfield or increment buttons provided.\n\nThe resulting total load, pipe size and pressure drop for this load type will be displayed to the right."
                
                
            default:
                print("Error: This should not occur")
            }
            
            
            
        default:
            print("Error: This should not occur")
        }
        
        
        
        //println("Row: \(indexPath.row) Loading Units: \(loadingUnits[indexPath.row])")
        
        // print("\(cell!.reuseIdentifier)")
        return cell!
        
    }
    
    
    
    // MARK: - Text Field Functions
    
    func textFieldEditingDidEnd(variableTextField:DemandUnitTF) {
        
        let indexPath:IndexPath = variableTextField.indexPath
        
        switch indexPath.section {
            
        case self.variableFluids.count - 1 + 1:
            
            // It's the pipe material section
            let material:Calculator.PipeMaterial = Calculator.PipeMaterial.all[indexPath.row]
            
            // Check valid entry
            if (variableTextField.text != "" && variableTextField.text!.floatValue >= 0.00000000001) {
                let newValue:Float = variableTextField.text!.floatValue
                calculator.setKValue(pipe: material, kValue: newValue)
            }
            
            // Reset the text so that stored value is actually displayed (this is need in case 2 decimal points are entered etc)
            if (material.kValue <= 0.0009) {
                
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.scientific
                formatter.usesSignificantDigits = false
                formatter.maximumSignificantDigits = 3
                formatter.minimumSignificantDigits = 3
                variableTextField.text = formatter.string(from: NSNumber(value: material.kValue))
                
            }
            else {
                variableTextField.text = String(format: "%.4f", material.kValue)
            }
            
        default:
            
            // It's a fluid section
            
            let fluid:Calculator.Fluid = self.variableFluids[variableTextField.indexPath.section]
            
            // Check valid entry
            if (variableTextField.text != "" && variableTextField.text!.floatValue >= 0.00000000001) { // dynamic viscoisty is 10^-5
                
                let newValue:Float = variableTextField.text!.floatValue
                
                switch variableTextField.indexPath.row {
                case 0:
                    calculator.setDensity(fluid: fluid, density: newValue)
                case 1:
                    calculator.setViscosity(fluid: fluid, visco: newValue)
                case 2:
                    calculator.setTemperatureDifference(fluid: fluid, dt: newValue)
                case 3:
                    calculator.setMaxPd(fluid: fluid, maxPd: newValue)
                default:
                    print("ERROR:\nCould not update value as this textfield doesn't correspond to a displayed property\nSee WaterPipeSettingsVC - textFieldEditingDidEnd\n")
                }
                
            }
            
            // The property values to be displayed in the first four rows
            let properties:[Float] = [fluid.density, fluid.visocity, fluid.temperatureDifference!, fluid.maxPdDefault]
            
            // Reset the text so that stored value is actually displayed (this is need in case 2 decimal points are entered etc)
            if (properties[variableTextField.indexPath.row] <= 0.009) {
                
                let formatter = NumberFormatter()
                formatter.numberStyle = NumberFormatter.Style.scientific
                formatter.usesSignificantDigits = false
                formatter.maximumSignificantDigits = 3
                formatter.minimumSignificantDigits = 3
                variableTextField.text = formatter.string(from: NSNumber(value: properties[variableTextField.indexPath.row]))
                
            }
            else {
                variableTextField.text = String(format: "%.2f", properties[variableTextField.indexPath.row])
            }
            
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
    
    func addBackgroundTap(_ view:UIControl) {
        view.addTarget(self, action: #selector(PipeSizerSettingsVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
    }
    
    
    func backgroundTapped(_ sender:AnyObject) {
        print("backgroundTapped")
        
        for tf in self.textFields {
            tf.resignFirstResponder()
        }
        
        self.keyboardHeightLayoutConstraint.constant = 0
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(PipeSizerSettingsVC.applyButtonAction))
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
