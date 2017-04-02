//
//  HomeVC.swift
//  Leaving Cert
//
//  Created by Richard Seaman on 11/04/2016.
//  Copyright © 2016 RichApps. All rights reserved.
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    
    // Order of appearance
    // Tools section
    let ductSizerIndex:Int = 0
    let pipeSizerIndex:Int = 1
    let networkSizerIndex:Int = 2
    let simDemandIndex:Int = 3
    let daylightIndex:Int = 4
    let settingsIndex:Int = 5
    // Other section
    let rateUsIndex:Int = 1
    let aboutIndex:Int = 0
    let termsIndex:Int = 2
    
    let numberOfRows = [6,3]
    
    // Table Variables
    var tableViewController = UITableViewController()
    let simpleCellIdentifier:String = "HomeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden : Bool {
        
        switch UIDevice.current.userInterfaceIdiom {
            
        case .phone:
            // It's an iPhone
            let orientation:Int = UIDevice.current.orientation.rawValue
            if (orientation == Int(UIInterfaceOrientation.landscapeLeft.rawValue) || orientation == Int(UIInterfaceOrientation.landscapeRight.rawValue)) {
                return true
            }
            else {
                return navigationController?.isNavigationBarHidden == true
            }
            
        case .pad:
            // It's an iPad
            return navigationController?.isNavigationBarHidden == true
            
        default:
            // Uh, oh! What could it be?
            print("Unknown device")
            return navigationController?.isNavigationBarHidden == true
            
        }
        
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.fade
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Make sure the nav bar image fits within the new orientation
        if (UIDevice.current.orientation.isLandscape) {
            
            // See constants file for size of image in landscape = 400/16
            if (self.navigationItem.titleView?.frame.height > 400/16) {
                self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
            }
            
        }
        
        // Reload Table incase colour changed
        self.tableView.reloadData()
        
    }
    
    
    
    // MARK: - Tableview methods
        
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfRows[section]
    }
    
    // Determine Number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        return 2
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view, colourOption: 0)
        
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        switch section{
        case 1:
            return "Other"
        default:
            return "Tools"
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: self.simpleCellIdentifier) as UITableViewCell?
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.simpleCellIdentifier)
        }
        
        let titleLabel:UILabel = cell!.viewWithTag(1) as! UILabel
        let detailLabel:UILabel = cell!.viewWithTag(2) as! UILabel
        let imageView:UIImageView = cell!.viewWithTag(3) as! UIImageView
        
        
        
        // Define the two height and width constraints of the image view
        let largeImageSize:CGFloat = 60
        let standardImageSize:CGFloat = 60
        
        let otherHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: standardImageSize)
        let otherWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: standardImageSize)
        
        let toolHeightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: largeImageSize)
        let toolWidthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: largeImageSize)
        
        // remove hangover constraints
        imageView.removeConstraints(imageView.constraints)
        
        cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        switch indexPath.section {
            
        case 1:
            
            // Other Section
            
            imageView.addConstraints([otherHeightConstraint, otherWidthConstraint])
            
            switch indexPath.row {
                
            case self.rateUsIndex:
                // Rate
                titleLabel.text = "Rate Us"
                detailLabel.text = "If you find The Building Services Toolbox useful, I'd really appreciate if you Rate it on the App Store!\nBut If you don't, I'd prefer if you didn't..."
                imageView.image = UIImage(named: "RateStar")!
            case self.aboutIndex:
                // About
                titleLabel.text = "About"
                detailLabel.text = "Find out more about The Building Services Toolbox."
                imageView.image = UIImage(named: "info")!
            case self.termsIndex:
                // Terms & Conditions
                titleLabel.text = "Terms & Conditions"
                detailLabel.text = "Review the terms and conditions of use."
                imageView.image = UIImage(named: "CheckBox")!
                
            default:
                titleLabel.text = ""
                detailLabel.text = nil
                imageView.image = nil
                
            }
            
        default:
            
            // Tools Section
            
            imageView.addConstraints([toolHeightConstraint, toolWidthConstraint])
            
            switch indexPath.row {
                
            case self.ductSizerIndex:
                // Duct Sizer
                titleLabel.text = "Duct Sizer"
                detailLabel.text = "Size circular or rectangular ductwork for a given flowrate or ACH."
                imageView.image = UIImage(named: "DuctSizer")!
            case self.pipeSizerIndex:
                // Pipe Sizer
                titleLabel.text = "Pipe Sizer"
                detailLabel.text = "Size pipework for a given flowrate or load."
                imageView.image = UIImage(named: "PipeSizer")!
            case self.networkSizerIndex:
                // Network Sizer
                titleLabel.text = "Network Pipe Sizer"
                detailLabel.text = "Size the pipework for a given heating/cooling network."
                imageView.image = UIImage(named: "PipeSizer")!
            case self.simDemandIndex:
                // Simultaneous Demand
                titleLabel.text = "Simultaneous Demand"
                detailLabel.text = "Calculate the simultaneous demand for a given collection of outlets and size the water services pipework required."
                imageView.image = UIImage(named: "SimDemand")!
            case self.daylightIndex:
                // Daylight Calculator
                titleLabel.text = "Daylight Calculator"
                detailLabel.text = "Calculate the average daylight factor for a standard room with given dimensions."
                imageView.image = UIImage(named: "Daylight")!
            case self.settingsIndex:
                // Settings
                titleLabel.text = "Variables"
                detailLabel.text = "Adjust the global variables that are used in the tools above."
                imageView.image = UIImage(named: "SettingsColor")!
                
            default:
                titleLabel.text = ""
                detailLabel.text = nil
                imageView.image = nil
                
            }
            
        }
        
        
        
        
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Animate de-selection regardless of cell...
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
            
        case 1:
            
            // other section
            switch indexPath.row {
            case self.rateUsIndex:
                
                // Google Analytics
                /*
                 if let tracker = GAI.sharedInstance().defaultTracker {
                 tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Ratings", action: "Rated", label: "From Homepage", value: nil).build()  as [NSObject : AnyObject])
                 }*/
                
                // Rate
                // Go to app store to rate
                print("Attempting to open:")
                print("itms-apps://itunes.apple.com/app/id\(APP_ID)")
                
                UIApplication.shared.openURL(URL(string : "itms-apps://itunes.apple.com/app/id\(APP_ID)")!)
            case self.aboutIndex:
                // About
                self.performSegue(withIdentifier: "toInfo", sender: self)
            case self.termsIndex:
                // Terms & Conditions
                print("Not implemented yet")
            //self.performSegue(withIdentifier: "toTerms", sender: self)
                
            default:
                print("No action for this cell")
                
            }

            
        default:
            
            // Tools section
            switch indexPath.row {
            case self.ductSizerIndex:
                // Duct Sizer
                self.performSegue(withIdentifier: "toDuctSizer", sender: self)
            case self.pipeSizerIndex:
                // Pipe Sizer
                self.performSegue(withIdentifier: "toPipeSizer", sender: self)
            case self.networkSizerIndex:
                // Network Sizer
                self.performSegue(withIdentifier: "toHeatNetworkSizer", sender: self)
            case self.simDemandIndex:
                // Simultaneous Demand ISzer
                self.performSegue(withIdentifier: "toSimDemand", sender: self)
            case self.daylightIndex:
                // Daylioght Calculator
                self.performSegue(withIdentifier: "toDaylight", sender: self)
            case self.settingsIndex:
                // Settings
                print("Not implemented yet")
                //self.performSegue(withIdentifier: "toSettings", sender: self)
                
            default:
                print("No action for this cell")
                
            }

            
        }
        
        
    }

    


}
