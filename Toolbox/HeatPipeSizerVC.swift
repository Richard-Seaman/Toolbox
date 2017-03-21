//
//  HeatPipeSizerVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 26/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit
import Darwin
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class HeatPipeSizerVC: UIViewController {
    
    // Error handling
    @IBOutlet weak var errorView: UIControl!
    @IBOutlet weak var totalErrorLabel: UILabel!
    let outOfRangeError:String = "Maximum pipe size can't achieve the required Pd/m at the current load.\nReduce the load and try again."
    
    
    // Outlets
    @IBOutlet var backGroundControlViews: [UIControl]!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    var textFields:[[LoadInfoTF]] = [[LoadInfoTF]]() // Just for tap background method
    
    let shaded:CGFloat = 0.5
    
    
    // Header
    @IBOutlet weak var pipeSizeLabel: UILabel!
    @IBOutlet weak var pipeImageView: UIImageView!
    @IBOutlet weak var totalLoadLabel: UILabel!
    @IBOutlet weak var totalFlowLabel: UILabel!
    @IBOutlet weak var totalPdLabel: UILabel!
    @IBOutlet weak var materialButton: UIButton!
    @IBOutlet weak var fluidButton: UIButton!
    @IBOutlet weak var maxPdTextfield: LoadInfoTF!
    
    // Tableview
    @IBOutlet weak var tableView: UITableView!
    var numberOfLoads:Int = 6
    var pipeSizes:[Int?] = [Int?]()
    var pipeSizeErrors:[String?] = [String?]()
    var dTs:[Float?] = [Float?]()
    var loads:[Float?] = [Float?]()
    var loadSet:[Bool?] = [Bool?]()
    var flows:[Float?] = [Float?]()
    var quantities:[Int?] = [Int?]()
    var pds:[Float?] = [Float?]()
    var loadLabels:[UILabel] = [UILabel]()
    var pipeSizeLabels:[UILabel] = [UILabel]()
    var pdLabels:[UILabel] = [UILabel]()
    var errorLabels:[UILabel] = [UILabel]()
    var errorViews:[UIControl] = [UIControl]()
    
    // Calculation
    var steelSelected:Bool = Bool()
    var lphwSelected:Bool = Bool()
    let steelNomDiamters:[Int] = [15,20,25,32,40,50,65,80,90,100,125,150,200]
    let steelIntDiameters:[Float] = [0.0161,0.0216,0.0274,0.036,0.0419,0.053,0.0687,0.0807,0.09315,0.1051,0.12995,0.1554,0.2191]
    let copperNomDiamters:[Int] = [15,22,28,35,42,54,67,76,108,133,159,219]
    let copperIntDiameters:[Float] = [0.0136,0.0202,0.0262,0.033,0.04,0.052,0.0643,0.0731,0.105,0.13,0.155,0.21]
    
    var lphwProperties:[Float] = [Float(),Float(),Float()]   // [C, rho, vis]
    var chwProperties:[Float] = [Float(),Float(),Float()]    // [C, rho, vis]
    
    var kSteel:Float = Float()
    var kCooper:Float = Float()
    
    var lphwDt:Float = Float()
    var chwDt:Float = Float()
    
    let pi:Float = Float(M_PI)
    
    var maxPd:Float = Float()
    
    // Results
    var totalPipeSize:Int? = Int()
    var totalLoad:Float? = Float()
    var totalFlow:Float? = Float()
    var totalPd:Float? = Float()
    var totalPipeSizeError:String? = String()
    

    // MARK: - System
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load in the pipe sizer properties
        self.loadProperties()
        
        // Listen for keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(HeatPipeSizerVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Max pd text field set up
        self.maxPdTextfield.clearsOnBeginEditing = true
        self.maxPdTextfield.adjustsFontSizeToFitWidth = true
        self.setupTextFieldInputAccessoryView(self.maxPdTextfield)
        self.maxPdTextfield.addTarget(self, action: #selector(HeatPipeSizerVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // self.tableView.separatorColor = UIColor.darkGrayColor() // Does work but the inset is still white so doesnlt look great
        
        // Apply the background tap function to the backgrounds
        for view in self.backGroundControlViews {
            self.addBackgroundTap(view)
        }
        
        
        self.setInitialValues()
        self.setUpButtons()
        self.setUpErrorView(self.errorView)
        
        // Add keyboard methods to textfiedls
        
        // Set up is finished, refresh the view
        self.refresh()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        // Load the properties incase they were changed in the settings and recalculate
        // All of which is done in refresh
        self.refresh()
        
        self.backgroundTapped(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        // Prevents keyboard issues
        self.backgroundTapped(self)
        
    }
    
    func loadProperties() {
        
        loadPipeSizerProperties()
        self.maxPd = pipeSizerProperties[0]
        self.kSteel = pipeSizerProperties[1]
        self.kCooper = pipeSizerProperties[2]
        self.lphwProperties = [pipeSizerProperties[3],pipeSizerProperties[4],pipeSizerProperties[5]]
        self.lphwDt = pipeSizerProperties[6]
        self.chwProperties = [pipeSizerProperties[7],pipeSizerProperties[8],pipeSizerProperties[9]]
        self.chwDt = pipeSizerProperties[10]
        
    }
    
    
    
    // MARK: - Set Up
    
    func setInitialValues() {
        
        print("setInitialValues")
        
        self.steelSelected = true
        self.lphwSelected = true
        
        // Empty variables
        self.textFields = [[LoadInfoTF]]()
        self.pipeSizes = [Int?]()
        self.dTs = [Float?]()
        self.loads = [Float?]()
        self.loadSet = [Bool?]()
        self.flows = [Float?]()
        self.quantities = [Int?]()
        self.pds = [Float?]()
        self.pipeSizeLabels = [UILabel]()
        self.loadLabels = [UILabel]()
        self.pipeSizeErrors = [String?]()
        self.pdLabels = [UILabel]()
        
        // Make the arrays the correct size
        
        for _ in 0..<self.numberOfLoads {
            
            // [kW, kg/s, Qty]
            let newTextFieldArray:[LoadInfoTF] = [LoadInfoTF(),LoadInfoTF(),LoadInfoTF()]
            self.textFields.append(newTextFieldArray)
            
            self.pipeSizeLabels.append(UILabel())
            self.loadLabels.append(UILabel())
            self.pipeSizeErrors.append(nil)
            self.pdLabels.append(UILabel())
            self.errorLabels.append(UILabel())
            self.errorViews.append(UIControl())
            
            self.pipeSizes.append(nil)
            self.dTs.append(nil)
            self.loads.append(nil)
            self.loadSet.append(nil)
            self.flows.append(nil)
            self.quantities.append(nil)
            self.pds.append(nil)
        }
        
        self.totalPipeSizeError = nil
        self.totalPipeSize = nil
        self.totalLoad = nil
        self.totalFlow = nil
        self.totalPd = nil
                
    }
    
    func setUpButtons() {
        
        // Add methods
        self.materialButton.addTarget(self, action: #selector(HeatPipeSizerVC.materialButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        self.fluidButton.addTarget(self, action: #selector(HeatPipeSizerVC.fluidButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        // Material Button Appearance - temporarily change to copper, then tap the button so it changes to steel and sets appearance
        self.steelSelected = false
        self.materialButtonTapped(self.materialButton)
        self.materialButton.layer.borderWidth = 2.5
        self.materialButton.layer.cornerRadius = 8
        self.materialButton.clipsToBounds = true
        
        // Fluid Button Appearance - temporarily change to copper, then tap the button so it changes to steel and sets appearance
        self.lphwSelected = false
        self.fluidButtonTapped(self.fluidButton)
        self.fluidButton.layer.borderWidth = 2.5
        self.fluidButton.layer.cornerRadius = 8
        self.fluidButton.clipsToBounds = true
        
        
    }
    
    func setUpErrorView(_ view:UIView) {
        
        view.alpha = 0
        view.layer.backgroundColor = UIColor.red.cgColor
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 2
        // view.layer.cornerRadius = 10
        
    }
    
    
    // MARK: - UI
    
    func refresh() {
        
        print("refresh")
        
        self.loadProperties()
        
        // Recalculate
        self.calculate()
        
        self.tableView.reloadData()
        
        // Update the textfield and label texts
        self.updateTextsAndLabels()
        
        print("  LoadSet  : \(self.loadSet)")
        print("  Loads    : \(self.loads)")
        print("  Quantity : \(self.quantities)")
        print("  PipeSizes: \(self.pipeSizes)")
        print("  Pds      : \(self.pds)")
        print("")
        print(" Total Flow: \(self.totalFlow)")
        print(" Total Size: \(self.totalPipeSize)")
        print(" Total Pd  : \(self.totalPd)")
        
    }
    
    
    func updateTextsAndLabels() {
        
        print("updateTextsAndLabels")
        // Individual rows are handled by the cellForRowAtIndexPath & updateTextFieldsForRow methods
        
        // ERROR VIEW
        if (self.totalPipeSizeError != nil) {
            self.errorView.alpha = 0.9
            self.totalErrorLabel.text = self.outOfRangeError    // Use this instead of whatever the string is in self.PipeSizeError
        }
        else {
            self.errorView.alpha = 0
        }
        
        // RESULTS
        
        // Set pipe Size text
        if let size = self.totalPipeSize {
            self.pipeSizeLabel.text = String(format: "%i mm", size)
        }
        else {
            self.pipeSizeLabel.text = "-- mm"
        }
        
        // Set total load text
        if let load = self.totalLoad {
            self.totalLoadLabel.text = String(format: "%.1f kW", load)
        }
        else {
            self.totalLoadLabel.text = "-- kW"
        }
        
        // Set total flow text
        if let flow = self.totalFlow {
            self.totalFlowLabel.text = String(format: "%.2f kg/s", flow)
        }
        else {
            self.totalFlowLabel.text = "-- kg/s"
        }
        
        // Set total pd text
        if let pd = self.totalPd {
            self.totalPdLabel.text = String(format: "%.0f Pa/m", pd)
        }
        else {
            self.totalPdLabel.text = "-- Pa/m"
        }
        
        self.maxPdTextfield.text = String(format: "%.0f", self.maxPd)
                
    }
    
    func updateRow(_ row:Int) {
      
        // Set kW text & alpha
        if let load = self.loads[row] {
            self.textFields[row][0].text = String(format: "%.1f", load)
            if (self.loadSet[row] != false) {
                self.textFields[row][0].alpha = 1
            }
            else {
                self.textFields[row][0].alpha = shaded
            }
            //print("  Load: \(load)")
        }
        else {
            self.textFields[row][0].text = ""
            self.textFields[row][0].alpha = 1
            //print("  Load: nil")
        }
        
        // Set kg/s text & alpha
        if let flow = self.flows[row] {
            self.textFields[row][1].text = String(format: "%.2f", flow)
            if (self.loadSet[row] != true) {
                self.textFields[row][1].alpha = 1
            }
            else {
                self.textFields[row][1].alpha = shaded
            }
            //print("  Flow: \(flow)")
        }
        else {
            self.textFields[row][1].text = ""
            self.textFields[row][1].alpha = 1
            
            //print("  Flow: nil")
        }
        
        // Set qty text
        if let qty = self.quantities[row] {
            self.textFields[row][2].text = String(format: "%i", qty)
            
            //print("  Qty: \(qty)")
        }
        else {
            self.textFields[row][2].text = ""
            
            //println("  Qty: nil")
        }
        
        // Calculate pipe size & pd
        if let flow = self.flows[row] {
            
            if let qty = self.quantities[row] {
                
                let combinedFlow:Float = flow * Float(qty)
                self.pipeSizes[row] = self.sizeFromFlow(combinedFlow).size
                self.pds[row] = self.sizeFromFlow(combinedFlow).pd
                
                if (self.pipeSizes[row] == nil) {
                    self.pipeSizeErrors[row] = "Flow too Large"
                }
                else {
                    self.pipeSizeErrors[row] = nil
                }
            }
        }
        else {
            self.pipeSizes[row] = nil
            self.pds[row] = nil
            self.pipeSizeErrors[row] = nil
        }
        
        // Set pipe size text
        if (self.pipeSizes[row] != nil && self.quantities[row] != nil) {
            let size = self.pipeSizes[row]!
            self.pipeSizeLabels[row].text = String(format: "%i mm", size)
            //print("  PipeSize: \(size)")
        }
        else {
            self.pipeSizeLabels[row].text = "-- mm"
            //println("  PipeSize: nil")
        }
        
        // Set pd text
        if (self.pds[row] != nil && self.quantities[row] != nil) {
            
            let pd = self.pds[row]!
            self.pdLabels[row].text = String(format: "%.0f Pa/m", pd)
            //print("  Pd: \(pd)")
        }
        else {
            self.pdLabels[row].text = "-- Pa/m"
            //println("  Pd: nil")
        }
        
        // Set combined load text
        if (self.loads[row] != nil && self.quantities[row] != nil) {
            let combinedLoad = self.loads[row]! * Float(self.quantities[row]!)
            self.loadLabels[row].text = String(format: "%.0f kW", combinedLoad)
            //print("  Combined Load: \(combinedLoad)")
        }
        else {
            self.loadLabels[row].text = "-- kW"
            //println("  Combined Load: nil")
        }
        
        // Set error view/label
        if (self.pipeSizeErrors[row] != nil) {
            self.errorLabels[row].text = "" // don't bother with label, just colour the background red and show it
            self.errorViews[row].alpha = 0.9
        }
        else {
            self.errorViews[row].alpha = 0
        }
        
    }
    
    // MARK: - Flowrates/Loads
    
    func updateLoadOrFlowForRow(_ sender:LoadInfoTF) {
        
        // Figure out if a load or flow textfield called this
        
        if (sender == self.textFields[sender.row][0]) {
            
            // Load value has already been updated, flow must be determined from new load (if its not nil)
            if let load = self.loads[sender.row] {
                self.flows[sender.row] = self.flowFromLoad(load)
                print("Load value used for row \(sender.row)")
                print("Flow value updated to \(self.flows[sender.row])")
                
                if (self.quantities[sender.row] == nil || self.quantities[sender.row] == 0) {
                    self.quantities[sender.row] = 1
                    print("Flowrate entered for row \(sender.row) but quantity was 0, automatically adding 1")
                }
                
                // Shade the textfields accordingly
                self.loadSet[sender.row] = true
                //self.textFields[sender.row][0].alpha = 1
                //self.textFields[sender.row][1].alpha = shaded
            }
            else {
                // If it's nil or 0, update flow to 0 and set quantity to 0 too
                self.flows[sender.row] = nil
                self.quantities[sender.row] = nil
                
                // Shade the textfields accordingly
                self.loadSet[sender.row] = nil
                //self.textFields[sender.row][0].alpha = 1
                //self.textFields[sender.row][1].alpha = 1
            }
            
            
            
        }
        else if (sender == self.textFields[sender.row][1]) {
            
            // Flow value has already been updated, load must be determined from new flow (if its not nil)
            if let flow = self.flows[sender.row] {
                self.loads[sender.row] = self.loadFromFlow(flow)
                print("Flow value used for row \(sender.row)")
                print("Load value updated to \(self.loads[sender.row])")
                
                if (self.quantities[sender.row] == nil || self.quantities[sender.row] == 0) {
                    self.quantities[sender.row] = 1
                    print("Flowrate entered for row \(sender.row) but quantity was 0, automatically adding 1")
                }
                
                // Shade the textfields accordingly
                self.loadSet[sender.row] = false
                //self.textFields[sender.row][0].alpha = shaded
                //self.textFields[sender.row][1].alpha = 1
            }
            else {
                // If it's nil or 0, update load to 0 and set quantity to 0 too
                self.loads[sender.row] = nil
                self.quantities[sender.row] = nil
                
                // Shade the textfields accordingly
                self.loadSet[sender.row] = nil
                //self.textFields[sender.row][0].alpha = 1
                //self.textFields[sender.row][1].alpha = 1
            }
            
        }
        
        
    }
    
    func flowFromLoad(_ load:Float) -> Float {
        
        if (self.lphwSelected) {
            return load / (self.lphwProperties[0] * self.lphwDt)
        }
        else {
            return load / (self.chwProperties[0]  * self.chwDt)
        }
        
        
        
    }
    
    func loadFromFlow(_ flow:Float) -> Float {
        if (self.lphwSelected) {
            return flow * self.lphwProperties[0] * self.lphwDt
        }
        else {
            return flow * self.chwProperties[0] * self.chwDt
        }
        
        
    }
    
    func updateFlowAfterFluidChange() {
        
        for index:Int in 0..<self.flows.count {
            
            // Check if there is a load
            if (self.loads[index] != nil) {
                
                // Check what was set to determine what needs to change - load or flowrate
                if (self.textFields[index][0].alpha == 1) {
                    
                    // Load was set, change the flowrate
                    self.flows[index] = self.flowFromLoad(self.loads[index]!)
                    
                }
                else {
                    
                    // Flow rate was set, change the load
                    self.loads[index] = self.loadFromFlow(self.flows[index]!)
                    
                }
            }
        }
    }
    
    
    // MARK: - Calculations
    
    func calculate() {
        
        
        // Determine total load & flow
        var totLoad:Float = 0
        var totFlow:Float = 0
        
        for index:Int in 0..<self.numberOfLoads {
            
            // Only sum if there is a load
            if let number = self.quantities[index] {
                
                // Only add if a flow/load been entered
                if let flow = self.flows[index] {
                    totFlow = totFlow + flow * Float(number)
                }
                if let load = self.loads[index] {
                    totLoad = totLoad + load * Float(number)
                }
            }
        }
        
        // Only update if not equal to 0 so nil value is not overridden with 0
        if (totLoad != 0) {
            self.totalLoad = totLoad
        }
        else {
            self.totalLoad = nil
        }
        if (totFlow != 0) {
            self.totalFlow = totFlow
        }
        else {
            self.totalFlow = nil
        }
        
        print("Total Load set to \(totLoad)")
        print("Total Flow set to \(totFlow)")
        
        if (self.totalFlow != nil) {
            
            if (self.sizeFromFlow(self.totalFlow!).size == nil) {
                
                // Flow too large, big enough pipe size not available for flow and max Pd
                self.totalPipeSizeError = "Flow too large"
                self.totalPipeSize = nil
                self.totalPd = nil
                
            }
            else {
                
                // Successfully sized pipe
                self.totalPipeSizeError = nil
                self.totalPipeSize = self.sizeFromFlow(self.totalFlow!).size
                self.totalPd = self.sizeFromFlow(self.totalFlow!).pd
                
            }
            
        }
        
        if (self.totalFlow == nil) {
            self.totalPipeSizeError = nil
            self.totalPipeSize = nil
            self.totalPd = nil

        }
        
        
    }
    
    func sizeFromFlow(_ flow:Float) -> (size:Int?, pd:Float?) {
        
        var diametersToUse:[Float] = [Float]()
        var nomDiametersToUse:[Int] = [Int]()
        
        if (self.steelSelected) {
            diametersToUse = self.steelIntDiameters
            nomDiametersToUse = self.steelNomDiamters
        }
        else {
            diametersToUse = self.copperIntDiameters
            nomDiametersToUse = self.copperNomDiamters
        }
        
        var rho:Float = Float()
        var visco:Float = Float()
        var k:Float = Float()
        
        if (self.lphwSelected) {
            rho = self.lphwProperties[1]
            visco = self.lphwProperties[2]
        }
        else {
            rho = self.chwProperties[1]
            visco = self.chwProperties[2]
        }
        
        if (self.steelSelected) {
            k = self.kSteel
        }
        else {
            k = self.kCooper
        }
        
        var size:Int? = nil
        var pdToReturn:Float? = nil
        
        for index:Int in 0..<diametersToUse.count {
        
            let d:Float = diametersToUse[index]
            let m:Float = flow          // kg/s
            let q:Float = m / rho       // m3/s
            let v:Float  = (q * 4) / (d * d * pi)  // m/s
            
            // Pd sub variables (formula is quite long)
            
            // Circ
            let a:Float = (6.9 * visco) / ( v * d) + powf((k/1000) / (3.71 * d), 1.11)
            
            let b:Float = -1.8 * log10(a)
            
            let c:Float = (0.5 * rho * v * v) / d
            
            
            
            // Pressure drop
            let pd = powf(1/b, 2) * c    // Pa/m
            
            if (pd <= self.maxPd) {
                size = nomDiametersToUse[index]
                pdToReturn = pd
                
                print("Properties used")
                print("k = \(k)")
                print("rho = \(rho)")
                print("visco = \(visco)")
                
                print("Variables used to size pipe")
                print("int. d = \(d)")
                print("nom. d = \(size)")
                print("m = \(m)")
                print("q = \(q)")
                print("v = \(v)")
                print("a = \(a)")
                print("b = \(b)")
                print("c = \(c)")
                print("pd = \(pd)")
                break
            }
            
        }
        
        // If a large enough size isn't found, nil will be returned
        return (size, pdToReturn)
    
    }
    
    
    
    // MARK: - TextField Functions
    
    func textFieldEditingDidEnd(_ sender:LoadInfoTF) {
        
        print("textFieldEditingDidEnd")
        
        // Check for blank entry
        if (sender.text != "") {
            
            var newValue:Float? = sender.text!.floatValue
            if (newValue == 0) {
                print("0 entered, setting value to nil")
                newValue = nil
            }
            
            // Check which text field's value was changed and update the variables accordingly
            
            if (sender == self.textFields[sender.row][0]) {
                // kW textField
                self.loads[sender.row] = newValue
                self.updateLoadOrFlowForRow(sender)
                print("kW for row \(sender.row) set to \(newValue)")
            }
            else if (sender == self.textFields[sender.row][1]) {
                // kg/s textField
                self.flows[sender.row] = newValue
                self.updateLoadOrFlowForRow(sender)
                print("kg/s for row \(sender.row) set to \(newValue)")
            }
            else if (sender == self.textFields[sender.row][2]) {
                // qty textField
                if (newValue != nil) {
                    self.quantities[sender.row] = Int(newValue!)
                }
                else {
                    self.quantities[sender.row] = nil
                }
                
                print("qty for row \(sender.row) set to \(newValue)")
            }
            else if (sender == self.maxPdTextfield) {
                // max Pd textfield 
                if (newValue != nil) {
                    self.maxPd = newValue!
                }
                
            }
            else {
                print("Could not find matching Text Field to update value")
            }
            
            
            
        }
        
        self.refresh()
        
    }
    
    
    
    // MARK: - Button Functions
    // Colours defined in constants file
    
    func materialButtonTapped(_ sender:UIButton) {
        
        print("materialButtonTapped")
        
        if (self.steelSelected) {
            
            // Change to copper
            self.steelSelected = false
            self.materialButton.setTitle("Copper", for: UIControlState())
            /*
            self.materialButton.tintColor = copperColour
            self.materialButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.materialButton.layer.borderColor = copperColour.CGColor
            */
            self.materialButton.tintColor = UIColor.white
            self.materialButton.layer.backgroundColor = copperColour.cgColor
            self.materialButton.layer.borderColor = UIColor.darkGray.cgColor
            
        }
        else {
            
            // Change to steel
            self.steelSelected = true
            self.materialButton.setTitle("Steel", for: UIControlState())
            /*
            self.materialButton.tintColor = UIColor.darkGrayColor()
            self.materialButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.materialButton.layer.borderColor = UIColor.darkGrayColor().CGColor
            */
            self.materialButton.tintColor = UIColor.white
            self.materialButton.layer.backgroundColor = steelColour.cgColor
            self.materialButton.layer.borderColor = UIColor.darkGray.cgColor

        }
        
        self.refresh()
        
    }
    
    func fluidButtonTapped(_ sender:UIButton) {
        
        print("fluidButtonTapped")
        
        if (self.lphwSelected) {
            
            // Change to CHW
            self.lphwSelected = false
            self.fluidButton.setTitle("CHW", for: UIControlState())
            /*
            self.fluidButton.tintColor = chwColour
            self.fluidButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.fluidButton.layer.borderColor = chwColour.CGColor
            */
            self.fluidButton.tintColor = UIColor.white
            self.fluidButton.layer.backgroundColor = chwColour.cgColor
            self.fluidButton.layer.borderColor = UIColor.darkGray.cgColor
            
        }
        else {
            
            // Change to LPHW
            self.lphwSelected = true
            self.fluidButton.setTitle("LPHW", for: UIControlState())
            /*
            self.fluidButton.tintColor = lphwColour
            self.fluidButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.fluidButton.layer.borderColor = lphwColour.CGColor
            */
            self.fluidButton.tintColor = UIColor.white
            self.fluidButton.layer.backgroundColor = lphwColour.cgColor
            self.fluidButton.layer.borderColor = UIColor.darkGray.cgColor
        }
        
        
        self.updateFlowAfterFluidChange()
        self.refresh()
        
    }
    
    
    func minusQtyButtonTapped(_ sender:LoadQuantityButton) {
        
        print("minusQtyButtonTapped for row: \(sender.row)")
        if (self.quantities[sender.row] == nil || self.quantities[sender.row] <= 1) {
            self.quantities[sender.row] = nil
        }
        else {
            self.quantities[sender.row] = self.quantities[sender.row]! - 1
        }
        
        self.refresh()
        
    }
    
    func plusQtyButtonTapped(_ sender:LoadQuantityButton) {
        
        print("plusQtyButtonTapped for row: \(sender.row)")
        if (self.quantities[sender.row] == nil || self.quantities[sender.row] == 0) {
            self.quantities[sender.row] = 1
        }
        else {
            self.quantities[sender.row] = self.quantities[sender.row]! + 1
        }
        
        self.refresh()
        
    }
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.numberOfLoads
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
        return 1
        
    }
    
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if (self.lphwSelected) {
            returnHeader(view, colourOption:1)
        }
        else {
            returnHeader(view, colourOption:2)
        }
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        return "Configure Loads"
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        // println("cellForRowAtIndexPath \(indexPath.row)")
        
        var cell:UITableViewCell? = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "HeatingLoadCell") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "HeatingLoadCell")
        }
        
        // Grab the components
        let loadLabel:UILabel = cell!.viewWithTag(6) as! UILabel
        self.loadLabels[indexPath.row] = loadLabel
        
        let pipeSizeLabel:UILabel = cell!.viewWithTag(8) as! UILabel
        self.pipeSizeLabels[indexPath.row] = pipeSizeLabel
        
        let pdLabel:UILabel = cell!.viewWithTag(7) as! UILabel
        self.pdLabels[indexPath.row] = pdLabel
        
        // Text fields = [kW, kg/s, Qty]
        var loadTextFields:[LoadInfoTF] = [cell!.viewWithTag(1) as! LoadInfoTF, cell!.viewWithTag(2) as! LoadInfoTF, cell!.viewWithTag(3) as! LoadInfoTF]
        
        let minusButton:LoadQuantityButton = cell!.viewWithTag(4) as! LoadQuantityButton
        let plusButton:LoadQuantityButton = cell!.viewWithTag(5) as! LoadQuantityButton
        
        let contentViews:[UIControl] = [cell!.viewWithTag(10) as! UIControl, cell!.viewWithTag(11) as! UIControl, cell!.viewWithTag(12) as! UIControl, cell!.viewWithTag(13) as! UIControl, cell!.viewWithTag(14) as! UIControl, cell!.viewWithTag(15) as! UIControl]
        
        /*
        var backGroundView:UIView = cell!.viewWithTag(20)!
        backGroundView.layer.borderColor = UIColor.darkGrayColor().CGColor
        backGroundView.layer.borderWidth = 1
        */
        
        // Add the error views and labels to their arrays
        let errorView:UIControl = cell!.viewWithTag(21) as! UIControl
        self.setUpErrorView(errorView)
        self.errorViews[indexPath.row] = errorView
        
        let errorLabel:UILabel = cell!.viewWithTag(22) as! UILabel
        self.errorLabels[indexPath.row] = errorLabel
        
        // Configure the text fields
        for index:Int in 0..<loadTextFields.count {
            
            loadTextFields[index].clearsOnBeginEditing = true
            loadTextFields[index].indexPath = indexPath
            loadTextFields[index].row = indexPath.row
            loadTextFields[index].adjustsFontSizeToFitWidth = true
            self.setupTextFieldInputAccessoryView(loadTextFields[index])
            loadTextFields[index].addTarget(self, action: #selector(HeatPipeSizerVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
            
        }
        
        // Make sure all the text field keyboards have been dismissed before they're replaced
        for textfield in self.textFields[indexPath.row] {
            textfield.resignFirstResponder()
        }
        
        // Add the text field array to the array of text fields
        self.textFields[indexPath.row] = loadTextFields
        
        
        // Configure the plus/minus buttons
        minusButton.addTarget(self, action: #selector(HeatPipeSizerVC.minusQtyButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        plusButton.addTarget(self, action: #selector(HeatPipeSizerVC.plusQtyButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        minusButton.row = indexPath.row
        minusButton.indexPath = indexPath
        plusButton.row = indexPath.row
        plusButton.indexPath = indexPath
        
        
        // Set background tap
        for view in contentViews {
            self.addBackgroundTap(view)
        }
        
        self.updateRow(indexPath.row)
        
        return cell!
        
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
            for textField in self.textFields[index] {
                textField.resignFirstResponder()
            }
        }
        self.maxPdTextfield.resignFirstResponder()
        self.keyboardHeightLayoutConstraint.constant = 0
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(HeatPipeSizerVC.applyButtonAction))
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

    
    func addBackgroundTap(_ view:UIControl) {
        
        view.addTarget(self, action: #selector(HeatPipeSizerVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        
    }
    

}
