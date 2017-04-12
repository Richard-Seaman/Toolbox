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
        case 1: // Contact
            return 3
        default:
            print("This section should not be here")
            return 0
            
        }
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        
        return 2
        
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        returnHeader(view)
        
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        
        let headings:[String] = ["About","Author's Note"]
        
        return headings[section]
        
    }
    
    // Make sure the header size is what we want
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderSizae
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        // Set the properties that are true for all or majority
        var cell:UITableViewCell = UITableViewCell()
        
        switch indexPath.section {
            
        case 0:
            // About
            switch indexPath.row {
                
            case 0:
                // First Row
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterTextCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                let versionString:String = getVersion()
                
                // Set the elements
                label.text = "The BSE Toolbox was developed as a useful app for engineers to use while they're out and about.\n\nVersion \(versionString)\n\n© 2017 Richard Seaman. All rights reserved."
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
            default:
                print("This indexPath should not be here section:\(indexPath.section) row:\(indexPath.row)")
            }
            
        case 1:
            
            // Contact
            switch indexPath.row {
                
            case 0:
                // Image row
                cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let imageView: UIImageView = cell.viewWithTag(1) as! UIImageView
                
                // Set the elements
                
                // Define the image size
                let imageSize:CGFloat = 200
                
                // Create the height & width constraints
                let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: imageSize)
                let widthConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: imageSize)
                
                // Add the constraints
                imageView.addConstraints([heightConstraint, widthConstraint])
                
                // Set the image
                imageView.image = UIImage(named: "profilePic")
                
                // Set the border
                imageView.layer.cornerRadius = imageSize / 2
                imageView.layer.borderWidth = 5
                imageView.layer.borderColor = primaryColour.cgColor
                
                
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                
            case 1:
                // Text Row
                cell = tableView.dequeueReusableCell(withIdentifier: "CenterTextItalicCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let label = cell.viewWithTag(1) as! UILabel
                
                // Set the elements
                label.text = "\"I developed the BSE Toolbox so that I could quickly check things while out of the office. It goes without saying that the tools provided are not intended to replace detailed calculations. I tried to make each tool as transparent as possible so that you know exactly what's happening behind the scenes.\n\nIf you wish to get in contact with me, you can use the email option on the main screen or the button below to open my LinkedIn page.\n\nIf you spot a bug, notice any strange results or just wish to pass along some suggestions or feedback, I'd be delighted to hear from you.\"\n\n- Richard Seaman\n"
                
                cell.isUserInteractionEnabled = false
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
            case 2:
                // Button Row
                cell = tableView.dequeueReusableCell(withIdentifier: "SingleButtonCell") as UITableViewCell!
                
                // Grab the elements using the tag
                let button = cell.viewWithTag(1) as! UIButton
                
                // Set the elements
                button.addTarget(self, action: #selector(InfoVC.contactRichardTapped), for: UIControlEvents.touchUpInside)
                button.setTitle("    View LinkedIn Page    ", for: UIControlState())
                
                button.layer.backgroundColor = primaryColour.cgColor
                button.layer.cornerRadius = 5
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.darkGray.cgColor
                
                // Don't highlight background when tapped outside button
                cell.isUserInteractionEnabled = true
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
