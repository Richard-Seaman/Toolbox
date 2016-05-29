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
    
    let methodSectionHeadings:[String] = ["Pipe Types","Methodology","Demand Units", "Flowrate"]
    
    let unitColumn:[String] = ["Demand Units","0","3","5","10","20","30","40","50","70","100","200","400","800","1000","1500","2000","5000","8000"]
    let flowColumn:[String] = ["Flowrate (kg/s)","0.00","0.15","0.20","0.30","0.42","0.55","0.70","0.80","1.00","1.25","2.20","3.50","6.00","7.00","9.00","15.0","20.0","30.0"]
    
    let sizeColumn:[String] = ["Pipe Size","15","22","28","35","42","54","67"]
    let maxFlowColumn:[String] = ["Max Flowrate (kg/s)","0.14","0.31","0.53","0.83","1.18","2.41","4.80"]
    
    // Loading Unit View
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var aboutView: UIControl!
    @IBOutlet weak var demandUnitsView: UIControl!
    @IBOutlet weak var demandUnitTableView: UITableView!
    
    @IBOutlet var headerViews: [UIControl]!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    var textFieldArrays:[[DemandUnitTF]] = [[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF](),[DemandUnitTF]()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WaterPipeSizerSettingsVC.keyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.selector.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.selectorDidChange), forControlEvents: UIControlEvents.ValueChanged)
        self.selector.tintColor = UIColor.darkGrayColor()
        
        self.setUpUI()
        
        // Apply the row height
        self.methodTableView.rowHeight = UITableViewAutomaticDimension;
        self.methodTableView.estimatedRowHeight = 64.0;
        
        self.demandUnitTableView.rowHeight = UITableViewAutomaticDimension;
        self.demandUnitTableView.estimatedRowHeight = 64.0;
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.sharedApplication().statusBarOrientation)
        
        // Also includes refresh method
        self.selectorDidChange()
        
        print("\(loadingUnits)")
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Save loading Units
        
        // Prevents keyboard issues
        self.backgroundTapped(self)
        
        // Save the values
        let filePath = loadingUnitsFilePath()
        let array = loadingUnits as NSArray
        if (array.writeToFile(filePath, atomically: true)) {
            print("Loading Units saved Successfully")
            
        }
        else {
            print("\nLoading Units could not be written to file\n")
            
        }
        
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
        
    }
    
    func setUpUI() {
        
        // Set borders & background tap
        for view in self.headerViews {
            self.addBorderAndBackgroundTap(view)
        }
                
    }
    
    func selectorDidChange() {
        
        switch self.selector.selectedSegmentIndex {
            
        case 0:
            self.demandUnitsView.alpha = 0
            self.aboutView.alpha = 1
        default:
            self.demandUnitsView.alpha = 1
            self.aboutView.alpha = 0
        }
        
        self.refresh()
    }
    
    func addBorderAndBackgroundTap(view:UIControl) {
        
        view.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.backgroundTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch tableView {
            
        case self.demandUnitTableView:
            return 14
            
        case self.methodTableView:
            
            switch section {
                
            case 0: // Pipe Type
                return 1
            case 1: // Methodology
                return 1
            case 2: // Step 1
                return self.unitColumn.count + 2
            case 3: // Step 2
                return self.sizeColumn.count + 1
            default:
                print("Error: This should not occur")
                return 0
            }
            
            
        default:
            print("Error: This should not occur")
            return 0
        }
        
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        
        switch tableView {
            
        case self.demandUnitTableView:
            return 1
            
        case self.methodTableView:
            return 4
            
        default:
            print("Error: This should not occur")
            return 0
        }
        
    }
    
    
    // Set properties of section header
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        switch tableView {
            
        case self.methodTableView:
            
            returnHeader(view, colourOption: 4)
            
        default:
            
            print("")
            
        }
        
    }
    
    
    // Assign Section Header Text
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch tableView {
            
        case self.methodTableView:
            
            return self.methodSectionHeadings[section]
            
        default: // Method
            
            return ""
            
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //println("cellForRowAtIndexPath \(indexPath.row)")
        
        var cell:UITableViewCell? = UITableViewCell()
        
        switch tableView {
            
        case self.demandUnitTableView:
            
            cell = tableView.dequeueReusableCellWithIdentifier("DemandUnitCell") as UITableViewCell!
            if (cell == nil) {
                print("new cell used")
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "DemandUnitCell")
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
            switch row {
                
            case 0, 2, 5, 10:   // Cold
                pipeImageView.image = UIImage(named: "C")
            case 11:   // Hot
                pipeImageView.image = UIImage(named: "H")
            case 12:   // Main
                pipeImageView.image = UIImage(named: "M")
            case 1, 3, 13:   // Rain
                pipeImageView.image = UIImage(named: "R")
            case 4, 6, 8, 9:   // Cold & Hot
                pipeImageView.image = UIImage(named: "CH")
            case 7:   // Cold & Hot & Main
                pipeImageView.image = UIImage(named: "CHM")
            default:    // Should never be the case
                pipeImageView.image = UIImage(named: "C")
            }
            
            
            // Set Outlet image
            switch row {
                
            case 0, 1:
                outletImageView.image = UIImage(named: "Toilet")
            case 2, 3:
                outletImageView.image = UIImage(named: "Urinal")
            case 4:
                outletImageView.image = UIImage(named: "WHB")
            case 5, 6, 7:
                outletImageView.image = UIImage(named: "Sink")
            case 8:
                outletImageView.image = UIImage(named: "Shower")
            case 9:
                outletImageView.image = UIImage(named: "Bath")
            case 10, 11, 12, 13:
                outletImageView.image = UIImage(named: "tap")
            default:    // Should never be the case
                outletImageView.image = UIImage(named: "Toilet")
            }
            
            // Set up the textfields
            var currentColumn:Int = 0
            for textField in textFields {
                textField.minimumFontSize = 5
                textField.adjustsFontSizeToFitWidth = true
                textField.addTarget(self, action: #selector(WaterPipeSizerSettingsVC.textFieldEditingDidEnd(_:)), forControlEvents: UIControlEvents.EditingDidEnd)
                textField.indexPath = indexPath
                textField.row = indexPath.row
                textField.column = currentColumn
                self.setupTextFieldInputAccessoryView(textField)
                currentColumn += 1
            }
            
            // Hide the non-applicable text fields in each row
            switch row {
                
            case 0, 2, 5 , 10:   // Cold
                textFields[0].alpha = 1
                textFields[1].alpha = 0
                textFields[2].alpha = 0
                textFields[3].alpha = 0
            case 11:   // Hot
                textFields[0].alpha = 0
                textFields[1].alpha = 1
                textFields[2].alpha = 0
                textFields[3].alpha = 0
            case 12:   // Main
                textFields[0].alpha = 0
                textFields[1].alpha = 0
                textFields[2].alpha = 1
                textFields[3].alpha = 0
            case 1, 3, 13:   // Rain
                textFields[0].alpha = 0
                textFields[1].alpha = 0
                textFields[2].alpha = 0
                textFields[3].alpha = 1
            case 4, 6, 8, 9:   // Cold & Hot
                textFields[0].alpha = 1
                textFields[1].alpha = 1
                textFields[2].alpha = 0
                textFields[3].alpha = 0
            case 7:   // Cold & Hot & Main
                textFields[0].alpha = 1
                textFields[1].alpha = 1
                textFields[2].alpha = 1
                textFields[3].alpha = 0
                
            default:    // Should never be the case
                textFields[0].alpha = 1
                textFields[1].alpha = 1
                textFields[2].alpha = 1
                textFields[3].alpha = 1
            }
            
            
            // Set the text field texts
            var index:Int = Int()
            for index = 0; index < textFields.count; index += 1 {
                if (loadingUnits[indexPath.row][index] != 0) {
                    textFields[index].text = String(format: "%.1f", loadingUnits[indexPath.row][index])
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
                
                cell = tableView.dequeueReusableCellWithIdentifier("PipeTypeCell") as UITableViewCell!
                if (cell == nil) {
                    print("new cell used")
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "PipeTypeCell")
                }
                
                
            case 1: // Methodology
                
                cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                if (cell == nil) {
                    print("new cell used")
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                }
                
                // Set up the cell components
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.text = "This calculation allows the Cold, Hot, Mains and Rain water pipe sizes to be determined for a given number of outlets.\n\nThe number of outlets are entered by using the plus and minus buttons or by typing in the number required. Any additional flowrates required may also be entered by using the text fields provided at the bottom of the screen.\n\nSome outlets have a number of piping arrangements. For example, a toilet may be fed by cold water or rain water. The arrangements may be toggled between by tapping on the pipe type indicator to the left of each outlet.\n\nOnce the data has been entered, the pipe sizes are determined by two simple steps."
                
            case 2: // Step 1
                
                switch indexPath.row {
                    
                case 0: // Explanation
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                    }
                    
                    // Set up the cell components
                    let label:UILabel = cell!.viewWithTag(1) as! UILabel
                    label.text = "The first step is to determine the number of demand units.\n\nThere are demand units associated with each outlet type and for each associated pipework arrangment. These demand units may be altered by selecting the 'Demand Units' tab at the top of this screen and editing the corresponding text fields.\n\nThe total number of demand units for each pipe is calculated by summing the product of the number of outlets and the corresponding demand units for each pipe type.\n\nOnce the total number of demand units has been determined for each pipe, the flowrate is interpolated from the following table"
                    
                case self.unitColumn.count + 1: // Source
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                    }
                    
                    // Set up the cell components
                    let label:UILabel = cell!.viewWithTag(1) as! UILabel
                    label.text = "These values were taken from 'Plumbing Engineering Services Design Guide, Graph 3: Pipe Sizing Chart - Copper and Stainless Steel'"
                    
                    
                default:    // Data Row
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("DataCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "DataCell")
                    }
                    
                    // Set up the cell components
                    let leftLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                    let rightLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                    leftLabel.text = self.unitColumn[indexPath.row-1]
                    rightLabel.text = self.flowColumn[indexPath.row-1]
                    
                }
                
            case 3: // Step 2
                
                switch indexPath.row {
                    
                case 0: // Explanation
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("MethodCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MethodCell")
                    }
                    
                    // Set up the cell components
                    let label:UILabel = cell!.viewWithTag(1) as! UILabel
                    label.text = "The second step is to determine each of the pipe sizes from the flowrates calculated in step 1. Any additional flowrates are added to the calculated flowrates.\n\nThe table below is used to determine the pipe sizes. Each pipe size has an associated maximum flowrate. If the pipe's flowrate is larger than the first size's maximum flowrate, the next size up is checked and so on until an acceptable size is found.\n\nIf the flowrate is too large, an 'Out of Range' error will occur. This means that the flowrate is greater than the maximum flowrate of the biggest pipe size in the table. In this case, you'll have to size the pipe yourself!"
                    
                    
                default:    // Data Row
                    
                    cell = tableView.dequeueReusableCellWithIdentifier("DataCell") as UITableViewCell!
                    if (cell == nil) {
                        print("new cell used")
                        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "DataCell")
                    }
                    
                    // Set up the cell components
                    let leftLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                    let rightLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                    leftLabel.text = self.sizeColumn[indexPath.row-1]
                    rightLabel.text = self.maxFlowColumn[indexPath.row-1]
                    
                }
                
                
            default:
                print("Error: This should not occur")
            }
            
            
            
        default:
            print("Error: This should not occur")
        }
        
        
        
        //println("Row: \(indexPath.row) Loading Units: \(loadingUnits[indexPath.row])")
        
        
        return cell!
        
    }
    
    
    // MARK: - Text Field Functions
    func textFieldEditingDidEnd(sender:DemandUnitTF) {
        print("flowTextFieldEditingDidEnd")
        
        if (sender.text != "") {
            
            // Make the changes to the loading Unit Record
            
            let loadingUnit = sender.text!.floatValue
            loadingUnits[sender.row][sender.column] = loadingUnit
            print("Loading Units Row:\(sender.row) Column:\(sender.column) set to \(loadingUnits[sender.row][sender.column])")
            
        }        
        
        // Update the texts
        self.setTextFieldText(sender)
        
    }
    
    
    func setTextFieldText(sender:DemandUnitTF) {
        print("setTextFieldText")
        
        if (loadingUnits[sender.row][sender.column] != 0) {
            sender.text = String(format: "%.1f", loadingUnits[sender.row][sender.column])
        }
        else {
            sender.text = ""
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
        
        for array in self.textFieldArrays {
            
            for textField in array {
                textField.resignFirstResponder()
                self.keyboardHeightLayoutConstraint.constant = 0
            }
            
        }
    }
    
    func setupTextFieldInputAccessoryView(sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.BlackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Done, target: self, action: #selector(WaterPipeSizerSettingsVC.applyButtonAction))
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
