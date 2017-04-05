//
//  WaterPipeSizerSettingsVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 19/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class WaterPipeSizerSettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Method View
    @IBOutlet weak var methodView: UIControl!
    @IBOutlet weak var methodTableView: UITableView!
    
    let methodSectionHeadings:[String] = ["Pipe Types","Methodology","Demand Units", "Pipe Sizing"]
    
    let unitColumn:[String] = ["Demand Units","0","3","5","10","20","30","40","50","70","100","200","400","800","1000","1500","2000","5000","8000"]
    let flowColumn:[String] = ["Flowrate (kg/s)","0.00","0.15","0.20","0.30","0.42","0.55","0.70","0.80","1.00","1.25","2.20","3.50","6.00","7.00","9.00","15.0","20.0","30.0"]
    
    
    // Variable View
    @IBOutlet weak var variableView: UIControl!
    @IBOutlet weak var variableTableView: UITableView!
    
    let numberOfRowsPerFluid:Int = 6
    
    let variableFluids:[Calculator.Fluid] = [.CWS, .HWS, .MWS, .RWS]
    let variableCellIdentifier:String = "WaterSizerVariableCell"
    let variableButtonCellIdentifier:String = "WaterSizerButtonCell"
    let variableSelectorCellIdentifier:String = "WaterSizerSelectorCell"
    
    // Array of variable textfields just so they can be dismissed
    var textFields:[DemandUnitTF] = [DemandUnitTF]()
    
    
    // Loading Unit View
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var aboutView: UIControl!
    @IBOutlet weak var demandUnitsView: UIControl!
    @IBOutlet weak var demandUnitTableView: UITableView!
    
    @IBOutlet var headerViews: [UIControl]!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    var textFieldArrays:[[DemandUnitTF]] = [[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF]()]

    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WaterPipeSizerSettingsVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.selector.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.selectorDidChange), for: UIControlEvents.valueChanged)
        self.selector.tintColor = UIColor.darkGray
        
        self.setUpUI()
        
        // Apply the row height
        self.methodTableView.rowHeight = UITableViewAutomaticDimension;
        self.methodTableView.estimatedRowHeight = 64.0;
        
        self.demandUnitTableView.rowHeight = UITableViewAutomaticDimension;
        self.demandUnitTableView.estimatedRowHeight = 64.0;
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refresh() {
        print("View refreshed")
        
        self.demandUnitTableView.reloadData()
        self.methodTableView.reloadData()
        self.variableTableView.reloadData()
        
    }
    
    func setUpUI() {
        print("setUpUI")
        
        // Set borders & background tap
        for view in self.headerViews {
            self.addBorderAndBackgroundTap(view)
        }
                
    }
    
    func selectorDidChange() {
        print("selectorDidChange")
        
        switch self.selector.selectedSegmentIndex {
            
        case 0:
            self.demandUnitsView.alpha = 0
            self.aboutView.alpha = 1
            self.variableView.alpha = 0
            self.methodTableView.reloadData()
        case 1:
            self.demandUnitsView.alpha = 1
            self.aboutView.alpha = 0
            self.variableView.alpha = 0
            self.demandUnitTableView.reloadData()
        default:
            self.demandUnitsView.alpha = 0
            self.aboutView.alpha = 0
            self.variableView.alpha = 1
            self.variableTableView.reloadData()
        }
        
    }
    
    func addBorderAndBackgroundTap(_ view:UIControl) {
        
        self.addBackgroundTap(view)
        
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    func addBackgroundTap(_ view:UIControl) {
        
        view.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        
    }
    
    
    func resetFluid(button:ButtonWithRow) {
        // The button tag corresponds to the fluid index
        if button.row < self.variableFluids.count {
            calculator.resetDefaultFluidProperties(fluid: self.variableFluids[button.row])
            self.variableTableView.reloadData()
        }
        
    }
    
    func setFluidPipe(selector:SegmentedControlWithRow) {
        // The segmented control tag corresponds to the fluid index
        if (selector.row < self.variableFluids.count) {
            calculator.setPipeMaterial(fluid: self.variableFluids[selector.row], material: Calculator.PipeMaterial.all[selector.selectedSegmentIndex])
        }
    }
    
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("numberOfRowsInSection")
        
        switch tableView {
            
        case self.demandUnitTableView:
            return Calculator.Outlets.all.count
            
        case self.methodTableView:
            
            switch section {
                
            case 0: // Pipe Type
                return 1
            case 1: // Methodology
                return 1
            case 2: // Step 1
                return self.unitColumn.count + 2
            case 3: // Step 2
                return 1
            default:
                print("Error: This should not occur")
                return 0
            }
            
        case self.variableTableView:
            
            return self.numberOfRowsPerFluid
            
            
        default:
            print("Error: This should not occur")
            return 0
        }
        
        
    }
    
    // Determine Number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        
        switch tableView {
            
        case self.demandUnitTableView:
            return 1
            
        case self.methodTableView:
            return 4
            
        case self.variableTableView:
            return self.variableFluids.count
            
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
    
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch tableView {
            
        case self.methodTableView:
            
            return self.methodSectionHeadings[section]
            
        case self.variableTableView:
            
            return self.variableFluids[section].description
            
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
                
            default:
                
                // NB: Fluids must be before other sections
                
                // Fluids
                let fluid:Calculator.Fluid = self.variableFluids[indexPath.section]
                
                // Rows:
                
                // Density
                // Viscosity
                // Max Pd
                // Max Velocity
                // Material Selector
                // Reset Defaults
                
                switch indexPath.row {
                    
                case 4:
                    
                    // Selector Cell
                    cell = tableView.dequeueReusableCell(withIdentifier: self.variableSelectorCellIdentifier) as UITableViewCell?
                    if (cell == nil) {
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.variableSelectorCellIdentifier)
                    }
                    
                    let selector:SegmentedControlWithRow = cell!.viewWithTag(1) as! SegmentedControlWithRow
                    let contentView:UIControl = cell!.viewWithTag(2) as! UIControl
                    
                    // Set background tap
                    self.addBackgroundTap(contentView)
                    
                    // Add an option for each Pipe Material
                    selector.removeAllSegments()
                    for index:Int in 0..<Calculator.PipeMaterial.all.count {
                        selector.insertSegment(withTitle: Calculator.PipeMaterial.all[index].material, at: index, animated: false)
                    }
                    // Set the row of the selector to the section so we know what fluid it represents when its tapped
                    selector.row = indexPath.section
                    selector.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.setFluidPipe(selector:)), for: .valueChanged)
                    selector.tintColor = UIColor.darkGray
                    
                    // Set currently selected material
                    if let index = Calculator.PipeMaterial.all.index(of: fluid.pipeMaterial) {
                        selector.selectedSegmentIndex = index
                    }
                    
                    
                case 5:
                    
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
                    button.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.resetFluid(button:)), for: UIControlEvents.touchUpInside)
                    
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
                    textField.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.textFieldEditingDidEnd(variableTextField:)), for: UIControlEvents.editingDidEnd)
                    textField.indexPath = indexPath
                    textField.row = indexPath.row
                    textField.column = indexPath.section
                    self.setupTextFieldInputAccessoryView(textField)
                    self.textFields.append(textField)
                    
                    // The property values to be displayed in the first four rows
                    let properties:[Float] = [fluid.density, fluid.visocity, fluid.maxPdDefault, fluid.maxVelocityDefault]
                    
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
                        descLabel.text = "Maximum pressure drop\n(Pa/m)"
                    case 3:
                        nameLabel.text = ""
                        descLabel.text = "Maximum velocity\n(m/s)"
                    default:
                        print("This row should not be here")                    
                    }
                    
                }
                
                
            }
            
        case self.demandUnitTableView:
            
            cell = tableView.dequeueReusableCell(withIdentifier: "DemandUnitCell") as UITableViewCell!
            if (cell == nil) {
                print("new cell used")
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DemandUnitCell")
            }
            
            let row:Int = indexPath.row
            
            // Set up the cell components
            let pipeImageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
            let outletImageView:UIImageView = cell!.viewWithTag(2) as! UIImageView
            
            var textFields:[DemandUnitTF] = [DemandUnitTF(),DemandUnitTF(),DemandUnitTF(),DemandUnitTF()]
            textFields[0] = cell!.viewWithTag(3) as! DemandUnitTF
            textFields[1] = cell!.viewWithTag(4) as! DemandUnitTF
            textFields[2] = cell!.viewWithTag(5) as! DemandUnitTF
            textFields[3] = cell!.viewWithTag(6) as! DemandUnitTF
            
            var columnsViews:[UIControl] = [UIControl]()
            columnsViews.append(cell!.viewWithTag(7) as! UIControl)
            columnsViews.append(cell!.viewWithTag(8) as! UIControl)
            columnsViews.append(cell!.viewWithTag(9) as! UIControl)
            columnsViews.append(cell!.viewWithTag(10) as! UIControl)
            columnsViews.append(cell!.viewWithTag(11) as! UIControl)
            columnsViews.append(cell!.viewWithTag(12) as! UIControl)
            
            // Set borders & background tap
            for view in columnsViews {
                self.addBorderAndBackgroundTap(view)
            }
            
            // Set Pipe image
            let outlet:Calculator.Outlets = Calculator.Outlets.all[row]
            
            pipeImageView.image = outlet.pipeImage
            outletImageView.image = outlet.outletImage
            
            
            // Set up the textfields
            var currentColumn:Int = 0
            for textField in textFields {
                textField.minimumFontSize = 5
                textField.adjustsFontSizeToFitWidth = true
                textField.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
                textField.indexPath = indexPath
                textField.row = indexPath.row
                textField.column = currentColumn
                self.setupTextFieldInputAccessoryView(textField)
                currentColumn += 1
            }
            
            // Hide the non-applicable text fields in each row
            // The demand units array [CWS_DU's, HWS_DU's, MWS_DU's, RWS_DU's]
            // The textfield array for each row corresponds to these DU's
            // Default to hidden
            textFields[0].alpha = 0
            textFields[1].alpha = 0
            textFields[2].alpha = 0
            textFields[3].alpha = 0
            // show if there's a demand unit
            for index:Int in 0..<4 {
                if (outlet.defaultDemandUnits[index] > 0) {
                    textFields[index].alpha = 1
                }
            }
            
            
            // Set the text field texts
            
            for index:Int in 0..<textFields.count  {
                
                if (outlet.demandUnits[index] != 0) {
                    textFields[index].text = String(format: "%.1f", outlet.demandUnits[index])
                }
                else {
                    textFields[index].text = ""
                }
                
            }
            
            // Add the textfields to the array of text field arrays
            self.textFieldArrays[indexPath.row] = textFields
            
        case self.methodTableView:
            
            switch indexPath.section {
                
            case 0: // Pipe Type
                
                cell = tableView.dequeueReusableCell(withIdentifier: "PipeTypeCell") as UITableViewCell!
                if (cell == nil) {
                    print("new cell used")
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "PipeTypeCell")
                }
                
                
            case 1: // Methodology
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    print("new cell used")
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "This calculation allows the Cold, Hot, Mains and Rain water pipe sizes to be determined for a given number of outlets.\n\nThe number of outlets are entered by using the plus and minus buttons or by typing in the number required. Any additional flowrates required may also be entered by using the text fields provided at the bottom of the screen.\n\nSome outlets have a number of piping arrangements. For example, a toilet may be fed by cold water or rain water. The arrangements may be toggled between by tapping on the pipe type indicator to the left of each outlet.\n\nOnce the data has been entered, the pipe sizes are determined by two simple steps."
                
            case 2: // Step 1
                
                switch indexPath.row {
                    
                case 0: // Explanation
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                    }
                    
                    // Set up the cell components
                    let label:UILabel = cell!.viewWithTag(1) as! UILabel
                    label.text = "The first step is to determine the number of demand units.\n\nThere are demand units associated with each outlet type and for each associated pipework arrangment. These demand units may be altered by selecting the 'Demand Units' tab at the top of this screen and editing the corresponding text fields.\n\nThe total number of demand units for each pipe is calculated by summing the product of the number of outlets and the corresponding demand units for each pipe type.\n\nOnce the total number of demand units has been determined for each pipe, the flowrate is interpolated from the following table"
                    
                case self.unitColumn.count + 1: // Source
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                    }
                    
                    // Set up the cell components
                    let label:UILabel = cell!.viewWithTag(1) as! UILabel
                    label.text = "These values were taken from 'Plumbing Engineering Services Design Guide, Graph 3: Pipe Sizing Chart - Copper and Stainless Steel'"
                    
                    
                default:    // Data Row
                    
                    cell = tableView.dequeueReusableCell(withIdentifier: "DataCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DataCell")
                    }
                    
                    // Set up the cell components
                    let leftLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                    let rightLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                    leftLabel.text = self.unitColumn[indexPath.row-1]
                    rightLabel.text = self.flowColumn[indexPath.row-1]
                    
                }
                
            case 3: // Step 2
                
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    print("new cell used")
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "Once the flowrates have been determined from the demand units for each service, the pipes can be sized. Any additional flowrates entered are added to the calculated flowrates before sizing the pipes.\n\nEach of the pipes are sized based on a maximum pressure drop, a maximum velocity and the selected pipework material. These variables may be edited from the 'Variables' tab at the top right of this screen.\n\nIf a water service is required to serve the combination of outlets selected, its pipe size, flowrate, velocity and pressure drop will be displayed at the top of the main screen. The pipe material is also indicated by the surrounding colour.\n\nIf the given constraints cannot be satisifed by the largest pipe size of the given material, an 'Out of Range' error will occur. In this case, you'll have to size the pipe yourself!"
                
                
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
                calculator.setMaxPd(fluid: fluid, maxPd: newValue)
            case 3:
                calculator.setMaxVelocity(fluid: fluid, maxVelocity: newValue)
            default:
                print("ERROR:\nCould not update value as this textfield doesn't correspond to a displayed property\nSee WaterPipeSettingsVC - textFieldEditingDidEnd\n")
            }
            
        }
        
        // The property values to be displayed in the first four rows
        let properties:[Float] = [fluid.density, fluid.visocity, fluid.maxPdDefault, fluid.maxVelocityDefault]
        
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
    
    func textFieldEditingDidEnd(_ sender:DemandUnitTF) {
        print("flowTextFieldEditingDidEnd")
        
        if (sender.text != "") {
            
            // Make the changes to the loading Unit Record
            
            let loadingUnit = sender.text!.floatValue
            let outlet = Calculator.Outlets.all[sender.row]
            
            var demandUnits = outlet.demandUnits
            demandUnits[sender.column] = loadingUnit
            
            calculator.setDemandUnits(outlet: outlet, CWS_DU: demandUnits[0], HWS_DU: demandUnits[1], MWS_DU: demandUnits[2], RWS_DU: demandUnits[3])            
            
        }        
        
        // Update the texts
        self.setTextFieldText(sender)
        
    }
    
    
    func setTextFieldText(_ sender:DemandUnitTF) {
        print("setTextFieldText")
        
        let outlet = Calculator.Outlets.all[sender.row]
        
        if (outlet.demandUnits[sender.column] != 0) {
            sender.text = String(format: "%.1f", outlet.demandUnits[sender.column])
        }
        else {
            sender.text = ""
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
        
        for array in self.textFieldArrays {
            
            for textField in array {
                textField.resignFirstResponder()
            }
            
        }
        
        for tf in self.textFields {
            tf.resignFirstResponder()
        }
        
        self.keyboardHeightLayoutConstraint.constant = 0
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(WaterPipeSizerSettingsVC.applyButtonAction))
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
