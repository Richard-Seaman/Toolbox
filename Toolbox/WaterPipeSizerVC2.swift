//
//  WaterPipeSizerVC2.swift
//  Toolbox
//
//  Created by Richard Seaman on 25/09/2015.
//  Copyright © 2015 RichApps. All rights reserved.
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
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


class WaterPipeSizerVC2: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var outletPipeTypeButtons:[PipeTypeButton] = [PipeTypeButton(),PipeTypeButton(),PipeTypeButton(),PipeTypeButton(),PipeTypeButton(),PipeTypeButton(),PipeTypeButton()]
    
    
    // Pipes
    @IBOutlet var pipeViews:[UIControl]!
    @IBOutlet var pipeSizeLabels:[UILabel]!
    @IBOutlet var pipeFlowLabels:[UILabel]!
    @IBOutlet var pipeVelocityLabels:[UILabel]!
    @IBOutlet var pipePdLabels:[UILabel]!
    @IBOutlet var pipeViewsInner:[UIControl]!
    
    
    // Text Fields
    var outletTextFields:[UITextField] = [UITextField(), UITextField(), UITextField(), UITextField(), UITextField(), UITextField(), UITextField()]
    var flowTextFields:[UITextField] = [UITextField(), UITextField(), UITextField(), UITextField()]
    
    // Fluids & Pipe Materials
    var fluids:[Calculator.Fluid] = [.CWS,.HWS,.MWS,.RWS]
    
    // Calculation Variables
    var pipeFlows:[Float] = [0,0,0,0]
    var pipeSizes:[Int?] = [nil,nil,nil,nil]
    var pipeVelocities:[Float?] = [nil,nil,nil,nil]
    var pipePressureDrops:[Float?] = [nil,nil,nil,nil]
    var errors:[String?] = [nil,nil,nil,nil]
    
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    let shaded:CGFloat = 0.3    // alpha value when shaded
    
    // Done in order of row
    var outletStrings:[String] = ["WC", "Urinal", "WHB", "Sink", "Shower", "Bath", "Tap"]
    var numberOfOutlets:[Int] = [0,0,0,0,0,0,0]
    var pipeTypeArray:[Int] = [0,0,1,2,1,1,0] // ["Cold","Cold & Hot","Cold & Hot & Main","Rain","Hot","Main"]
    let maxNumberOfOutlets:Int = 99
    
    let pipeStrings:[String] = ["Cold","Hot","Main","Rain"]
    var addFlows:[Float] = [0,0,0,0]
    
    
    
    // MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self, selector: #selector(WaterPipeSizerVC2.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Set up flow views
        for view in self.pipeViews {
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.darkGray.cgColor
            // Add tap background
            view.addTarget(self, action: #selector(WaterPipeSizerVC2.backgroundTapped), for: UIControlEvents.touchUpInside)
        }
        
        // Set the background colour according to the fluid
        // And the borders (edge of pipes)
        for index:Int in 0..<self.pipeViews.count {
            if (index < self.fluids.count) {
                self.pipeViewsInner[index].backgroundColor = self.fluids[index].colour
                self.pipeViewsInner[index].layer.borderWidth = 1
                self.pipeViewsInner[index].layer.borderColor = UIColor.darkGray.cgColor
                self.pipeViews[index].layer.borderWidth = 1
                self.pipeViews[index].layer.borderColor = UIColor.darkGray.cgColor
                // Note: outter colour (pipe material colour) is set in refresh as this is dynamic
            } else {
                print("ERROR: Not enough fluids for number of pipe views")
            }
        }
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0;
        
        // Done in viewWillAppear instead
        //self.refresh()
        
    }    
    
    override func viewWillAppear(_ animated: Bool) {
        self.backgroundTapped()
        // Refresh eah time it appears in case parameters changed in settings view and we're returning to this one - need to recalculate
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Refresh
    
    func refresh() {
        
        // Set the border colour according to the material selected for each fluid
        for index:Int in 0..<self.pipeViews.count {
            if (index < self.fluids.count) {
                self.pipeViews[index].backgroundColor = self.fluids[index].pipeMaterial.colour
            } else {
                print("ERROR: Not enough fluids for number of pipe views")
            }
        }
        
        self.determinePipeSizes()
        
        self.tableView.reloadData()
        
        // Set the results labels
        for index:Int in 0 ..< self.pipeSizeLabels.count {
            
            let sizeLabel:UILabel = self.pipeSizeLabels[index]
            let size:Int? = self.pipeSizes[index]
            
            let flowLabel:UILabel = self.pipeFlowLabels[index]
            let flow:Float = self.pipeFlows[index]
            
            let veloctyLabel:UILabel = self.pipeVelocityLabels[index]
            let velocity:Float? = self.pipeVelocities[index]
            
            let pressureDropLabel:UILabel = self.pipePdLabels[index]
            let pd:Float? = self.pipePressureDrops[index]
            
            // Set the size label and also the alpha value of the view
            let outOfRangeError:String = "Out Of Range"
            
            if (self.errors[index] != nil) {
                sizeLabel.text = "???"
                self.pipeViews[index].alpha = 1
            }
            else if let actualSize = size {
                sizeLabel.text = String(format: "%i mm", actualSize)
                self.pipeViews[index].alpha = 1
            }
            else {
                sizeLabel.text = "-- mm"
                self.pipeViews[index].alpha = shaded
            }
            
            if (self.errors[index] != nil) {
                flowLabel.text = outOfRangeError
            }
            else if (flow > 0) {
                flowLabel.text = String(format: "%.2f kg/s", flow)
            }
            else {
                flowLabel.text = "-- kg/s"
            }
            
            if (self.errors[index] != nil) {
                veloctyLabel.text = outOfRangeError
            }
            else if let actualVelocity = velocity {
                veloctyLabel.text = String(format: "%.1f m/s", actualVelocity)
            }
            else {
                veloctyLabel.text = "-- m/s"
            }
            
            if (self.errors[index] != nil) {
                pressureDropLabel.text = outOfRangeError
            }
            else if let actualPd = pd {
                pressureDropLabel.text = String(format: "%.1f Pa/m", actualPd)
            }
            else {
                pressureDropLabel.text = "-- Pa/m"
            }
        }
        
    }


    
    // MARK: -  Calculation
    
    func determinePipeSizes() {
        
        print("determinePipeSizes")
        
        // Empty the erros
        self.errors = [nil,nil,nil,nil]
        
        // Number of Outlets Served
        // ["WC", "Urinal", "WHB", "Sink", "Shower", "Bath", "Tap"]
        
        // Loading Units Applied -> ["WC", "Urinal", "WHB", "Sink", "Shower", "Bath"]
        var loadingUnitsApplied:[[Float]] = [[Float]]()
        
        // WC loading units
        if (self.outletPipeTypeButtons[0].combination == 0) {
            loadingUnitsApplied.append(Calculator.Outlets.WC_C.demandUnits) // WC - cold
        }
        else {
            loadingUnitsApplied.append(Calculator.Outlets.WC_R.demandUnits) // WC - rain
        }
        
        // Urinal loading units
        if (self.outletPipeTypeButtons[1].combination == 0) {
            loadingUnitsApplied.append(Calculator.Outlets.Urinal_C.demandUnits) // Urinal - cold
        }
        else {
            loadingUnitsApplied.append(Calculator.Outlets.Urinal_R.demandUnits) // Urinal - rain
        }
        
        // WHB loading units
        loadingUnitsApplied.append(Calculator.Outlets.WHB_CH.demandUnits)     // WHB - cold & hot
        
        // Sink loading units
        if (self.outletPipeTypeButtons[3].combination == 0) {
            loadingUnitsApplied.append(Calculator.Outlets.Sink_C.demandUnits) // Sink - cold
        }
        else if (self.outletPipeTypeButtons[3].combination == 1) {
            loadingUnitsApplied.append(Calculator.Outlets.Sink_CH.demandUnits) // Sink - cold & hot
        }
        else {
            loadingUnitsApplied.append(Calculator.Outlets.Sink_CHM.demandUnits) // Sink - cold & hot & mains
        }
        
        // Shower loading units
        loadingUnitsApplied.append(Calculator.Outlets.Shower_CH.demandUnits)     // Shower - cold & hot
        
        // Bath loading units
        loadingUnitsApplied.append(Calculator.Outlets.Bath_CH.demandUnits)     // Bath - cold & hot
        
        // Tap loading units
        if (self.outletPipeTypeButtons[6].combination == 0) {
            loadingUnitsApplied.append(Calculator.Outlets.Tap_C.demandUnits) // Tap - cold
        }
        else if (self.outletPipeTypeButtons[6].combination == 4) {
            loadingUnitsApplied.append(Calculator.Outlets.Tap_H.demandUnits) // Tap - hot
        }
        else if (self.outletPipeTypeButtons[6].combination == 5) {
            loadingUnitsApplied.append(Calculator.Outlets.Tap_M.demandUnits) // Tap - mains
        }
        else {
            loadingUnitsApplied.append(Calculator.Outlets.Tap_R.demandUnits) // Tap - rain
        }
        
        // Determine Total Demand
        var totalLoadingUnits:[Float] = [0,0,0,0]
        
        // Cycle through each outlet type
        for index:Int in 0..<numberOfOutlets.count {
            
            for pipeTypeIndex:Int in 0..<totalLoadingUnits.count {
                
                totalLoadingUnits[pipeTypeIndex] = totalLoadingUnits[pipeTypeIndex] + Float(numberOfOutlets[index]) * loadingUnitsApplied[index][pipeTypeIndex]
                
            }
            
        }
        
        
        // NOTE: At this point the loading/demand units are known
        
        // Cycle through each of the pipes
        for index:Int in 0..<self.pipeViews.count {
            
            // Try to size the pipe
            let results = calculator.resultsForSimDemand(fluid: self.fluids[index], demandUnits: totalLoadingUnits[index], additionalMassFlowrate: self.addFlows[index], material: self.fluids[index].pipeMaterial)
            
            // Add the errors (if there's none, it will be nil
            self.errors[index] = results.errorDesc
            
            // Check that we got results
            if let pipeResults = results.result {
                
                // Add them to the corresponding arrays
                self.pipeSizes[index] = pipeResults.nomDia
                self.pipeFlows[index] = pipeResults.massFlowrate
                self.pipeVelocities[index] = pipeResults.velocity
                self.pipePressureDrops[index] = pipeResults.pd
                
                // If the flowrate was 0, manually set results to nil (so the pipeviews are shaded)
                if (pipeResults.massFlowrate == 0) {
                    self.pipeSizes[index] = nil
                    self.pipeFlows[index] = 0
                    self.pipeVelocities[index] = nil
                    self.pipePressureDrops[index] = nil
                }
                
            } else {
                
                // If we didn't get results, set to nil
                self.pipeSizes[index] = nil
                self.pipeFlows[index] = 0
                self.pipeVelocities[index] = nil
                self.pipePressureDrops[index] = nil
                
            }
            
        }
        
        print("\nDemand Units: \(totalLoadingUnits)\nAdditional Flowrates: \(self.addFlows)\nFlowrates: \(self.pipeFlows)\nSizes: \(self.pipeSizes)\nVelocities: \(self.pipeVelocities)\nPressureDrops: \(self.pipePressureDrops)\nErrors: \(self.errors)\n")
        
        
    }
    
    



    // MARK: - Tableview methods


    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            
        case 0:
            return 7 // Outlets
        case 1:
            return 2 // Flows
        default:
            print("error")
            return 1
        }
        
    }

    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
        return 2
        
    }

    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view, colourOption: 4)
        
    }

    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        let headings:[String] = ["Add Outlets","Add Flowrates"]
        return headings[section]
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell:UITableViewCell? = UITableViewCell()
        
        switch indexPath.section {
            
        case 0:
            
            // Outlets section
            
            cell = tableView.dequeueReusableCell(withIdentifier: "OutletCell") as UITableViewCell!
            if (cell == nil) {
                // print("new cell used")
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "OutletCell")
            }
            
            
            // Grab up the cell components
            let changePipeTypeButton:PipeTypeButton = cell!.viewWithTag(1) as! PipeTypeButton
            let outletImageView:UIImageView = cell!.viewWithTag(2) as! UIImageView
            let outletTextField:TextFieldWithRow = cell!.viewWithTag(3) as! TextFieldWithRow
            let minusButton:ButtonWithRow = cell!.viewWithTag(4) as! ButtonWithRow
            let plusButton:ButtonWithRow = cell!.viewWithTag(5) as! ButtonWithRow
            let clearButton:ButtonWithRow = cell!.viewWithTag(6) as! ButtonWithRow
            
            let countView:UIControl = cell!.viewWithTag(7) as! UIControl
            let imageContainerView:UIControl = cell!.viewWithTag(8) as! UIControl
            
            // Set Pipe type (will automatically set image)
            changePipeTypeButton.combination = self.pipeTypeArray[indexPath.row]
            changePipeTypeButton.row = indexPath.row
            changePipeTypeButton.addTarget(self, action: #selector(WaterPipeSizerVC2.changePipeTypeTapped(_:)), for: UIControlEvents.touchUpInside)
            self.outletPipeTypeButtons[indexPath.row] = changePipeTypeButton
            
            // Set Outlet image
            switch indexPath.row {
                
            case 0:
                outletImageView.image = UIImage(named: "Toilet")
            case 1:
                outletImageView.image = UIImage(named: "Urinal")
            case 2:
                outletImageView.image = UIImage(named: "WHB")
            case 3:
                outletImageView.image = UIImage(named: "Sink")
            case 4:
                outletImageView.image = UIImage(named: "Shower")
            case 5:
                outletImageView.image = UIImage(named: "Bath")
            case 6:
                outletImageView.image = UIImage(named: "tap")
            default:    // Should never be the case
                outletImageView.image = UIImage(named: "Toilet")
            }
            
            // Set up the textfield
            outletTextField.text = String(format: "%i", self.numberOfOutlets[indexPath.row])
            outletTextField.addTarget(self, action: #selector(WaterPipeSizerVC2.outletTextFieldEditDidEnd(_:)), for: UIControlEvents.editingDidEnd)
            outletTextField.row = indexPath.row
            self.setupTextFieldInputAccessoryView(outletTextField)
            self.outletTextFields[indexPath.row] = outletTextField
            
            // Set up the plus/minus/clear buttons
            plusButton.row = indexPath.row
            minusButton.row = indexPath.row
            clearButton.row = indexPath.row
            
            plusButton.addTarget(self, action: #selector(WaterPipeSizerVC2.plusButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            minusButton.addTarget(self, action: #selector(WaterPipeSizerVC2.minusButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            clearButton.addTarget(self, action: #selector(WaterPipeSizerVC2.outletClearButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            
            // Assign background taps to views
            countView.addTarget(self, action: #selector(WaterPipeSizerVC2.backgroundTapped), for: UIControlEvents.touchUpInside)
            imageContainerView.addTarget(self, action: #selector(WaterPipeSizerVC2.backgroundTapped), for: UIControlEvents.touchUpInside)
            
            
        case 1:
            
            // Flow section
            
            cell = tableView.dequeueReusableCell(withIdentifier: "FlowCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "FlowCell")
            }
            
            // Grab up the cell components
            let leftImageView:UIImageView = cell!.viewWithTag(1) as! UIImageView
            let leftTextField:TextFieldWithRow = cell!.viewWithTag(2) as! TextFieldWithRow
            let leftClearButton:ButtonWithRow = cell!.viewWithTag(3) as! ButtonWithRow
            
            let rightImageView:UIImageView = cell!.viewWithTag(4) as! UIImageView
            let rightTextField:TextFieldWithRow = cell!.viewWithTag(5) as! TextFieldWithRow
            let rightClearButton:ButtonWithRow = cell!.viewWithTag(6) as! ButtonWithRow
            
            let leftView:UIControl = cell!.viewWithTag(7) as! UIControl
            let rightView:UIControl = cell!.viewWithTag(8) as! UIControl
            
            
            // Assign pipe images
            switch indexPath.row {
                
            case 0:
                leftImageView.image = UIImage(named: "CL")
                rightImageView.image = UIImage(named: "ML")
            case 1:
                leftImageView.image = UIImage(named: "HL")
                rightImageView.image = UIImage(named: "RL")
            default:
                print("error - unexpected switch case")
            }
            
            // Set up flow text fields
            
            // self.addFlows -> [Cold, Hot, Main, Rain]
            leftTextField.text = String(format: "%.2f kg/s", self.addFlows[indexPath.row])
            rightTextField.text = String(format: "%.2f kg/s", self.addFlows[indexPath.row + 2])
            
            leftTextField.row = indexPath.row
            rightTextField.row = indexPath.row + 2
            
            leftTextField.addTarget(self, action: #selector(WaterPipeSizerVC2.flowTextFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
            rightTextField.addTarget(self, action: #selector(WaterPipeSizerVC2.flowTextFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
            
            self.setupTextFieldInputAccessoryView(leftTextField)
            self.setupTextFieldInputAccessoryView(rightTextField)
            
            self.flowTextFields[indexPath.row] = leftTextField
            self.flowTextFields[indexPath.row + 2] = rightTextField
            
            
            // Set up the clear buttons
            leftClearButton.row = indexPath.row
            rightClearButton.row = indexPath.row + 2
            
            leftClearButton.addTarget(self, action: #selector(WaterPipeSizerVC2.flowClearButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            rightClearButton.addTarget(self, action: #selector(WaterPipeSizerVC2.flowClearButtonTapped(_:)), for: UIControlEvents.touchUpInside)
            
            
            // Background taps
            leftView.addTarget(self, action: #selector(WaterPipeSizerVC2.backgroundTapped), for: UIControlEvents.touchUpInside)
            rightView.addTarget(self, action: #selector(WaterPipeSizerVC2.backgroundTapped), for: UIControlEvents.touchUpInside)
            
            
            
        default:
            print("This section should not be here")
            
            
        }
        
        
        return cell!
        
    }
    
    
    // MARK: - Flow functions
    
    func flowTextFieldEditingDidEnd(_ sender:TextFieldWithRow) {
        
        print("flow textField editing did end @ index \(sender.row)")
        
        if (sender.text != "") {
            
            // acceptable value entered - but make sure convertible to Float (should always be the case)
            if (sender.text!.floatValue != 0) {
                self.addFlows[sender.row] = sender.text!.floatValue
            }
            else {
                // Couldn't convert to float
                print("Could not convert \(sender.text) to Float Value, value set to previous\n\n")
            }
        }
        
        print("Additional flow for \(self.pipeStrings[sender.row]) Pipe set to \(self.addFlows[sender.row]) kg/s")
        
        self.refresh()
        
        
        
    }
    
    func flowClearButtonTapped(_ sender:ButtonWithRow) {
        
        print("clear flow button tapped @ index \(sender.row)")
        
        self.addFlows[sender.row] = 0
        self.refresh()
        
    }
    
    
    // MARK: - Outlet functions
    
    func changePipeTypeTapped(_ sender:PipeTypeButton) {
        
        print("pipe type button tapped @ row \(sender.row)")
        
        // Only applies to certain rows
        switch sender.row {
            
        case 0,1:
            // WC or Urinal
            
            switch sender.combination {
                
            case 0: // If its Cold, set it to Rain
                sender.combination = 3
            default: // If its not Cold, set it to Cold
                sender.combination = 0
            }
            
        case 3:
            // Sink
            
            switch sender.combination {
                
            case 0: // If its Cold, set it to Cold & Hot
                sender.combination = 1
            case 1: // If its Cold & Hot, set it to Cold & Hot & Main
                sender.combination = 2
            default: // If its anything else, set it to Cold
                sender.combination = 0
            }
            
            
        case 6:
            // Tap
            
            switch sender.combination {
                
            case 0: // If its Cold, set it to  Hot
                sender.combination = 4
            case 4: // If its Hot, set it to Main
                sender.combination = 5
            case 5: // If its Main, set it to Rain
                sender.combination = 3
            default: // If its anything else, set it to Cold
                sender.combination = 0
            }
            
        default:
            print("there is only one combination available for this outlet type")
            
        }
        
        self.pipeTypeArray[sender.row] = sender.combination
        
        print("Combination changed to \(sender.combinationStrings[sender.combination])")
        self.refresh()
        
        
    }
    
    func outletTextFieldEditDidEnd(_ sender:TextFieldWithRow) {
        
        print("outlet textField editing did end @ row \(sender.row)")
        
        if (sender.text != "") {
            
            // acceptable value entered - but make sure convertible to Int (should always be the case)
            if let newNumber = Int(sender.text!) {
                
                // Make sure it's less than the maximum number of outlets
                if (newNumber > maxNumberOfOutlets) {
                    self.numberOfOutlets[sender.row] = maxNumberOfOutlets
                }
                else {
                    self.numberOfOutlets[sender.row] = newNumber
                }
            }
            else {
                // Couldn't convert to integer
                print("Could not convert \(sender.text) to Integer, value set to previous\n\n")
            }
        }
        
        self.refresh()
        print("No. of \(self.outletStrings[sender.row])s set to \(self.numberOfOutlets[sender.row])")
        
        
    }
    
    func outletClearButtonTapped(_ sender:ButtonWithRow) {
        
        print("clear button tapped @ row \(sender.row)")
        
        self.numberOfOutlets[sender.row] = 0
        self.refresh()
        
    }
    
    func minusButtonTapped(_ sender:ButtonWithRow) {
        
        print("minus button tapped @ row \(sender.row)")
        
        // If there are any outlets, take one away
        if (self.numberOfOutlets[sender.row] != 0) {
            self.numberOfOutlets[sender.row] = self.numberOfOutlets[sender.row] - 1
        }
        
        self.refresh()
        
    }
    
    func plusButtonTapped(_ sender:ButtonWithRow) {
        
        print("plus button tapped @ row \(sender.row)")
        
        // Add an outlet if it's less than the max allowed
        if (self.numberOfOutlets[sender.row] < self.maxNumberOfOutlets) {
            self.numberOfOutlets[sender.row] = self.numberOfOutlets[sender.row] + 1
        }
        
        self.refresh()
        
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
    
    func backgroundTapped() {
        print("backgroundTapped")
        
        for textField in self.outletTextFields {
            textField.resignFirstResponder()
        }
        
        for textField in self.flowTextFields {
            textField.resignFirstResponder()
        }
        
        self.keyboardHeightLayoutConstraint.constant = 0
        
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(WaterPipeSizerVC2.backgroundTapped))
        done.tintColor = UIColor.white
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        sender.inputAccessoryView = doneToolbar
        
    }
    

}
