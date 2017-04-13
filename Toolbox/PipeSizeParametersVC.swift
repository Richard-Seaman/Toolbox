//
//  PipeSizeParametersVC.swift
//  Toolbox
//
//  Created by Richard Seaman on 12/04/2017.
//  Copyright © 2017 RichApps. All rights reserved.
//

import UIKit

class PipeSizeParametersVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Table Variables
    var tableViewController = UITableViewController()
    let dataCellIdentifier:String = "DataCell"
    @IBOutlet weak var tableView: UITableView!
    
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Google Analytics
        let name = "Pipe Diameters"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
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
    

    
    
    // MARK: - Tableview methods
    
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Calculator.PipeMaterial.all[section].internalDiameters.count + 1
    }
    
    // Determine Number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        return Calculator.PipeMaterial.all.count
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        returnHeader(view)
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return Calculator.PipeMaterial.all[section].material + " Pipe Sizes"
    }
    
    // Make sure the header size is what we want
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderSizae
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: self.dataCellIdentifier) as UITableViewCell?
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: self.dataCellIdentifier)
        }        
        
        // Set up the cell components
        let leftLabel:UILabel = cell!.viewWithTag(1) as! UILabel
        let rightLabel:UILabel = cell!.viewWithTag(2) as! UILabel
        
        // Enable multiple lines
        leftLabel.numberOfLines = 0
        rightLabel.numberOfLines = 0
        
        if (indexPath.row == 0) {
            leftLabel.text = "Nominal Diameter\n(mm)"
            rightLabel.text = "Internal Diameter\n(mm)"
        } else {
            let nomDiameter:Int = Calculator.PipeMaterial.all[indexPath.section].nominalDiameters[indexPath.row - 1]
            let intDiameter:Float = Calculator.PipeMaterial.all[indexPath.section].internalDiameters[indexPath.row - 1] * 1000
            
            leftLabel.text = String(format: "%i", nomDiameter)
            rightLabel.text = String(format: "%.1f", intDiameter)
        }
        
        cell?.isUserInteractionEnabled = false
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Animate de-selection regardless of cell...
        tableView.deselectRow(at: indexPath, animated: true)
        
    }


}
