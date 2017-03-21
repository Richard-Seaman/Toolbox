//
//  DuctSizerSettingsVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 26/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class DuctSizerSettingsVC: UIViewController {
    
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    // Variable View (also used for method view)
    @IBOutlet var variableView: UIControl!
    @IBOutlet weak var tableView: UITableView!
    var textFields: [UITextField] = [UITextField(),UITextField(),UITextField()]
    var sectionHeadingsVariables: [String] = ["Properties","Dimensions","Results"]
    var sectionHeadingsMethod: [String] = ["Methodology","Flowrate","Manual Sizing","Automatic Sizing"]
    
    // Formulae View
    @IBOutlet var formulaeView: UIControl!
    @IBOutlet weak var webview: UIWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(DuctSizerSettingsVC.keyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.selector.addTarget(self, action: #selector(DuctSizerSettingsVC.selectorDidChange), for: UIControlEvents.valueChanged)
        self.selector.tintColor = UIColor.darkGray
        
        self.setUpUI()
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0;
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Also includes refresh method
        self.selectorDidChange()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // In case coming from settings, need to recalculate
        self.refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Save the values
        let filePath = ductSizerPropertiesFilePath()
        let array = ductSizerProperties as NSArray
        if (array.write(toFile: filePath, atomically: true)) {
            print("Duct Sizer Properties saved Successfully")
            
        }
        else {
            print("\nDuct Sizer Properties could not be written to file\n")
            
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
        self.backgroundTapped(self)
        loadDuctSizerProperties()
        self.tableView.reloadData()
        
    }
    
    func setUpUI() {
        
        // Set background tap
        
        let views:[UIControl] = [self.formulaeView, self.variableView]
        
        for view in views {
            self.addBackgroundTap(view)
        }
        
        let formulaePath:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "DuctSizerFormulae", ofType: "pdf")!)
        
        // Load the formulae into the web view
        self.webview.loadRequest(URLRequest(url: formulaePath))
        
    }
    
    func addBackgroundTap(_ view:UIControl) {
        
        view.addTarget(self, action: #selector(DuctSizerSettingsVC.backgroundTapped(_:)), for: UIControlEvents.touchUpInside)
        
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
    
    func resetDefaults() {
        print("resetDefaults")
        resetDuctSizerPropertiesDefaults()
        self.refresh()
    }
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
          
        case 0: // Method
            return 1
            
        case 1: // Variables
            switch section {
                
            case 0: // Properties
                return 4
            case 1: // Dimensions
                return 4
            case 2: // Results
                return 4
            default:
                return 0
            }
            
        default: // Formulae
            return 0
            
        }
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view, colourOption: 4)
        
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        //println("cellForRowAtIndexPath \(indexPath.row)")
        var cell:UITableViewCell? = UITableViewCell()
        
        // Method - Variables - Formulae
        
        switch self.selector.selectedSegmentIndex {
          
        case 0: // Method
            
            if (indexPath.section == 0) {
                
                // Methodology
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "This calculation allows you to size circular and rectangular ductwork."
                
            }
            else if (indexPath.section == 1) {
                
                // Flowrate
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "To begin, you need to enter a flowrate at the top of the screen. A m3/s or m3/hr value may be input directly. Alternatively, a room area and an air change per hour (ACH) may be used.\n\nThe flowrate method being used will be highlighted to avoid confusion.\n\nOnce the flowrate has been determined, the duct may be sized manually or automatically."
                
            }
            else if (indexPath.section == 2) {
                
                // Manual Sizing
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The size of the dimensions may be altered by using the sliders provided or by typing in the dimension in the textfields.\n\nThe sliders have a minimum and maximum dimension of 100mm and 1000mm respectively and an increment of 50mm.\n\nOnce the duct size is changed, the velocity and pressure drop calculations will be redone and the results will be displayed."
                
            }
            else if (indexPath.section == 3) {
                
                // Automatic Sizing
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 0
                
                label.text = "The autosize calculation determines the minimum duct size that meets the maximum velocity limit.\n\nIn order to automatically size the duct, a maximum velocity must be provided. One of the preset velocities may be used by selecting the corresponding tab at the bottom of the screen. To define the velocity for autosizing, the custom tab must be selected and the velocity must be entered into the text field.\n\nWhen sizing rectangular ducts, an aspect ratio may be defined by using the textfield at the bottom right of the screen. If no aspect ratio is entered, the duct dimensions will be incremented in turn until the required velocity is achieved. The width or height of the duct may also be locked, preventing the dimension from changing during the autosizing procedure."
                
            }
            else {
                
                // Dummy cell with error
                cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
                }
                
                let label:UILabel = cell!.viewWithTag(1) as! UILabel
                label.numberOfLines = 1
                
                label.text = "This cell should not be here..."
                
            }
            
        case 1: // Variables
            
            if (indexPath.section == 0 && indexPath.row == 3) {
                
                // Reset defaults button
                cell = tableView.dequeueReusableCell(withIdentifier: "DuctSizerButtonCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DuctSizerButtonCell")
                }
                
                let button:UIButton = cell!.viewWithTag(1) as! UIButton
                let contentView:UIControl = cell!.viewWithTag(2) as! UIControl
                
                // Set background tap
                self.addBackgroundTap(contentView)
                
                button.layer.borderColor = UIColor.darkGray.cgColor
                button.layer.borderWidth = 1.5
                button.layer.cornerRadius = 5
                button.layer.backgroundColor = UIColor.white.cgColor
                button.setTitle("    Reset Defaults    ", for: UIControlState())
                button.tintColor = UIColor.darkGray
                button.addTarget(self, action: #selector(DuctSizerSettingsVC.resetDefaults), for: UIControlEvents.touchUpInside)
                
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "DuctSizerVariableCell") as UITableViewCell!
                if (cell == nil) {
                    cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "DuctSizerVariableCell")
                }
                
                // Grab the components
                let nameLabel:UILabel = cell!.viewWithTag(1) as! UILabel
                let descLabel:UILabel = cell!.viewWithTag(2) as! UILabel
                let textField:UITextField = cell!.viewWithTag(3) as! UITextField
                let contentView:UIControl = cell!.viewWithTag(4) as! UIControl
                
                // Set background tap
                self.addBackgroundTap(contentView)
                
                // Text field set up
                switch indexPath.section {
                    
                case 0: // Only the properties section have editable values (in their textfields)
                    
                    // Add textField to array (there's only three entries in the array, for the three rows in the properties section)
                    self.textFields[indexPath.row] = textField
                    
                    // Set up the textfield
                    textField.alpha = 1
                    textField.minimumFontSize = 5
                    textField.adjustsFontSizeToFitWidth = true
                    textField.addTarget(self, action: #selector(DuctSizerSettingsVC.textFieldEditingDidEnd(_:)), for: UIControlEvents.editingDidEnd)
                    self.setupTextFieldInputAccessoryView(textField)
                    
                    // Set the text field texts
                    if (ductSizerProperties[indexPath.row] <= 0.009) {
                        
                        let formatter = NumberFormatter()
                        formatter.numberStyle = NumberFormatter.Style.scientific
                        formatter.usesSignificantDigits = false
                        formatter.maximumSignificantDigits = 3
                        formatter.minimumSignificantDigits = 3
                        textField.text = formatter.string(from: NSNumber(value: ductSizerProperties[indexPath.row]))
                    }
                    else {
                        textField.text = String(format: "%.2f", ductSizerProperties[indexPath.row])
                    }
                    
                    
                default:
                    // Hide the non-applicable text fields in each row
                    textField.alpha = 0
                }
                
                // Label set up
                switch indexPath.section {
                    
                case 0: // Properties
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = "rho"
                        descLabel.text = "Density of air\n(kg/m3)"
                    case 1:
                        nameLabel.text = "vis"
                        descLabel.text = "Dynamic viscosity of air\n(kg/ms)"
                    case 2:
                        nameLabel.text = "k"
                        descLabel.text = "Duct k value\n(k/mm)"
                    default:
                        nameLabel.text = ""
                        descLabel.text = ""
                    }
                    
                case 1: // Dimensions
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = "x"
                        descLabel.text = "Duct width\n(m)"
                    case 1:
                        nameLabel.text = "y"
                        descLabel.text = "Duct height\n(m)"
                    case 2:
                        nameLabel.text = "d"
                        descLabel.text = "Duct diameter\n(m)"
                    case 3:
                        nameLabel.text = "dh"
                        descLabel.text = "Hydraulic diameter\n(m)"
                    default:
                        nameLabel.text = ""
                        descLabel.text = ""
                    }
                    
                case 2: // Results
                    
                    switch indexPath.row {
                        
                    case 0:
                        nameLabel.text = "Vr"
                        descLabel.text = "Rectangular velocity\n(m/s)"
                    case 1:
                        nameLabel.text = "Vc"
                        descLabel.text = "Circular velocity\n(m/s)"
                    case 2:
                        nameLabel.text = "Pdr"
                        descLabel.text = "Rectangular pressure drop\n(Pa/m)"
                    case 3:
                        nameLabel.text = "Pdc"
                        descLabel.text = "Circular pressure drop\n(Pa/m)"
                    default:
                        nameLabel.text = ""
                        descLabel.text = ""
                    }
                    
                default:
                    nameLabel.text = ""
                    descLabel.text = ""
                }
            }
            
            
        default: // Method
            
            // Dummy cell with error
            cell = tableView.dequeueReusableCell(withIdentifier: "MethodCell") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "MethodCell")
            }
            
            let label:UILabel = cell!.viewWithTag(1) as! UILabel
            label.numberOfLines = 1
            
            label.text = "This cell should not be here..."
            
        }
               
        
        return cell!
        
    }
    
    
    // MARK: - Text Field Functions
    func textFieldEditingDidEnd(_ sender:UITextField) {
        print("flowTextFieldEditingDidEnd")
        
        // Make the changes to the Property Record
        for index:Int in 0..<self.textFields.count {
            // Find the right textField
            if (sender == self.textFields[index]) {
                
                // Check valid entry
                if (sender.text != "" && sender.text!.floatValue >= 0.00000000001) { // dynamic viscoisty is 10^-5
                    ductSizerProperties[index] = sender.text!.floatValue
                }
                
                // Reset the text so that stored value is actually displayed (this is need in case 2 decimal points are entered etc)
                if (sender.text!.floatValue <= 0.009) {
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.scientific
                    formatter.usesSignificantDigits = false
                    formatter.maximumSignificantDigits = 3
                    formatter.minimumSignificantDigits = 3
                    sender.text = formatter.string(from: NSNumber(value: ductSizerProperties[index]))
                    
                }
                else {
                    sender.text = String(format: "%.2f", ductSizerProperties[index])
                }
                
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
    
    func backgroundTapped(_ sender:AnyObject) {
        print("backgroundTapped")
        
        for textField in self.textFields {
            textField.resignFirstResponder()
            self.keyboardHeightLayoutConstraint.constant = 0
        }
            
        
    }
    
    func setupTextFieldInputAccessoryView(_ sender:UITextField) {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.done, target: self, action: #selector(DuctSizerSettingsVC.applyButtonAction))
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
