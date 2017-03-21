//
//  NewInfoVC.swift
//  Leaving Cert
//
//  Created by Richard Seaman on 08/09/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewController = UITableViewController()
    
    // MARK: - System
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden : Bool {
        let orientation:Int = UIDevice.current.orientation.rawValue
        if (orientation == Int(UIInterfaceOrientation.landscapeLeft.rawValue) || orientation == Int(UIInterfaceOrientation.landscapeRight.rawValue)) {
            return true
        }
        else {
            return navigationController?.isNavigationBarHidden == true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Prevent blank space appearing at top
        self.automaticallyAdjustsScrollViewInsets = true
        
    }
    
    
    // MARK: - Setup
    
    
    // MARK: - Button functions
    
    func contactRichardTapped() {
        print("Called: contactRichardTapped")
        
        UIApplication.shared.openURL(URL(string: "https://ie.linkedin.com/pub/richard-seaman/60/b11/9b4")!)
        
    }
    
    
    // MARK: - Tableview methods
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //println("Determining rows in section")
        
        switch section {
            
        case 0: // About
            return 1
        case 1: // Features
            return 1
        case 2: // Contact
            return 2
        case 3: // Disclaimer
            return 1
        default:
            print("This section should not be here")
            return 0
            
        }
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
        return 4
        
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view)
        
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        let headings:[String] = ["About","Features","Author's Note","Disclaimer"]
        
        return headings[section]
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        // Set the properties that are true for all or majority
        var cell:UITableViewCell = UITableViewCell()
        
        switch indexPath.section {
            
        case 0:
            // First Section - About
            switch indexPath.row {
                
            case 0:
                // First Row
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterTextCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                let versionString:String = getVersion()
                
                // Set the elements
                label.text = "M&E Toolbox was developed as a useful app for engineers to use while they're out and about.\n\nVersion \(versionString)\n\n© 2017 Richard Seaman. All rights reserved."
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
            default:
                print("This indexPath should not be here section:\(indexPath.section) row:\(indexPath.row)")
            }
            
        case 1:
            
            // Second Section - Features
            switch indexPath.row {
                
            case 0:
                // Text Row
                cell = tableView.dequeueReusableCell(withIdentifier: "LeftTextCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                // Set the elements
                label.text = "This application offers a number of 'tools' including a duct sizer, a LPHW/CHW pipe sizer, a water pipe sizer (based on simultaneous demand) and a simplified daylight factor calculator.\n\nAdditional content and features may be added to later versions."
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
            default:
                print("This indexPath should not be here section:\(indexPath.section) row:\(indexPath.row)")
            }
            
        case 2:
            
            // Third Section - Contact
            switch indexPath.row {
                
            case 0:
                // Text Row
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterTextItalicCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                // Set the elements
                label.text = "\"I developed M&E Toolbox so that I could quickly check things while out of the office. The tools provided are not intended to replace detailed calculations and can only be used for quick checks. I tried to make each tool as transparent as possible so that you know exactly what's happening behind the scenes.\n\nIf you wish to get in contact with me, you can use the button below to open my LinkedIn page in Safari.\n\nIf you spot a bug, notice any strange results or just wish to pass along some suggestions or feedback, I'd be delighted to hear from you.\"\n\n- Richard Seaman\n"
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
            case 1:
                // Button Row
                cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let button = cell.viewWithTag(1) as! UIButton
                
                // Set the elements
                button.addTarget(self, action: #selector(InfoVC.contactRichardTapped), for: UIControlEvents.touchUpInside)
                button.setTitle("Contact Richard", for: UIControlState())
                
                button.layer.backgroundColor = UIColor(red: 205/255, green: 28/255, blue: 1/255, alpha: 1.0).cgColor
                button.layer.cornerRadius = 2.5
                
                // Don't highlight background when tapped outside button
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
            default:
                print("This indexPath should not be here section:\(indexPath.section) row:\(indexPath.row)")
            }
            
        case 3:
            
            // Fourth Section - Disclaimer
            switch indexPath.row {
                
            case 0:
                // Text Row
                cell = tableView.dequeueReusableCell(withIdentifier: "LeftTextCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                // Set the elements
                label.text = "This application provides a number of tools. The author of this app takes no responsibility for the accuracy of the tools and this application is used entirely at the user's risk. The author of this app reserves the right not to update or service the application at their discretion.\n\nThe author of this app takes no responsibility for any damage caused to the hardware that it is installed on or any responsibility for any loss of data or software that occurs as a result of its use.\n\nThis application is licensed as freeware and may be used without charge. The application and the concepts used are the intellectual property of its author."
                
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
            default:
                print("This indexPath should not be here section:\(indexPath.section) row:\(indexPath.row)")
            }
            
            
        default:
            print("This section should not be here section:\(indexPath.section)")
            cell = UITableViewCell()
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        // Animate de-selection regardless of cell...
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    
    
}
