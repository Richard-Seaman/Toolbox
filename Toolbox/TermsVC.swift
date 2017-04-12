//
//  TermsVC.swift
//  Leaving Cert
//
//  Created by Richard Seaman on 02/09/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class TermsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var tableViewController = UITableViewController()
    let cellIdentifier = "BasicCell"
    
    var terms:[String] = [String]()
    
    // LOCK TO PORTRAIT
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNeedsStatusBarAppearanceUpdate()
        
        // Google Analytics
        /*
        let name = "View Terms"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Make sure it's in portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var prefersStatusBarHidden : Bool {
        // Always portrait
        return false
        
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(toInterfaceOrientation)
        
        self.view.layoutIfNeeded()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 64.0;
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Load the terms
        self.setTerms()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refresh() {
        
        self.tableView.reloadData()
        
    }
    
    
    
    // MARK: - Tableview methods
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.terms.count
        
    }
    
    // Determine Number of sections
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int{
        return 1
        
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {        
        returnHeader(view)
    }
    
    // Make sure the header size is what we want
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return defaultHeaderSizae
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return "Terms and Conditions"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        //println("Determining cell for row at indexPath: \(indexPath.section),\(indexPath.row)")
        
        var cell:UITableViewCell = UITableViewCell()
        
        cell = tableView.dequeueReusableCell(withIdentifier: "TermCell") as UITableViewCell!
        
        let label:UILabel = cell.viewWithTag(1) as! UILabel
        
        label.numberOfLines = 0
        label.font = UIFont(name: label.font.fontName, size: 14)
        
        let term:String = self.terms[indexPath.row]
        let number:Int = indexPath.row
        
        if number == 0 {
            label.text = "Definitions.\n\n" + term
        } else {
            label.text = String(format: "%i.\n\n%@", number, term)
        }
        
        
        return cell
        
    }
    
    
    func setTerms() {
     
        // Empty the array
        self.terms = [String]()
        
        // Input the terms
        
        // Definitions is first
        self.terms.append("The term ‘author’ or ‘us’ or ‘we’ or ‘I’ refers to the creator of the Building Services Engineering Toolbox, Richard Seaman. The term ‘you’ or ‘user’ refers to the user of the Building Services Engineering Toolbox application.")
        
        // Each of the following terms are numbered in the order they appear below
        self.terms.append("By using this application, you are agreeing to comply with and be bound by the following terms and conditions of use. If you disagree with any part of these terms and conditions you shall remove this application from your device.")
        
        self.terms.append("Users may only use this application for their own personal purposes.")
        
        self.terms.append("This application is used entirely at the user’s own risk. I take no responsiblility for any damage caused to the hardware that it is installed on or any responsibility for any loss of data or software that occurs as a result of its use.")
        
        self.terms.append("I take no responsibility for any costs incurred through the use of this application.")
        
        self.terms.append("I shall not be responsible or liable for the accuracy, usefulness or availability of any information transmitted or made available by this application.")
        
        self.terms.append("The Building Services Toolbox and its orginal content, features and functionality are owned by Richard Seaman and are protected by international copyright and other intellectual property laws.")
        
        self.terms.append("I reserve the right to make changes to the information and services provided by this application at any time without notice and without liability.")
        
        self.terms.append("I reserve the right to not update and/or to terminate the services provided by this application without cause or notice.")
        
        self.terms.append("I reserve the right to add, amend or vary the terms of conditions of this agreement and the continued use of this application will signify your acceptance of the changes. It is therefore recommended that you periodically check these Terms and Conditions which can be accessed from the Home page.")
        
        self.terms.append("This application uses Google Analytics to collect and analyse usage data as well as information on your device properties. Based on this data, I can provide better services as well as analyse and further develop the application. This data is treated as non-personal data. By using this application you're consenting to the collecting and processing of your information as described above.")
    }
    
}
