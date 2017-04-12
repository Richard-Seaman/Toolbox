//
//  AcceptTermsVC.swift
//  Leaving Cert
//
//  Created by Richard Seaman on 02/09/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class AcceptTermsVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var readSwitch: UISwitch!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    
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
        
        // Set up the switch
        self.readSwitch.isOn = false
        self.switchChanged(self.readSwitch)
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        // Prevent blank space appearing at top
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set the outlets
        self.setUpLabels()
        self.setUpButtons()
        self.setUpSwitch()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set(1, forKey: "ACCEPTEDTERMS")
        prefs.synchronize()
        
        // Dismiss VC (go back to launch which will redirect to home)
        self.dismiss(animated: false, completion: nil)
        
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        
        if (sender.isOn == true) {
            
            self.acceptButton.isUserInteractionEnabled = true
            self.acceptButton.alpha = 1
        }
        else {
            self.acceptButton.isUserInteractionEnabled = false
            self.acceptButton.alpha = 0.5
        }
        
        
    }
    
    func setUpSwitch() {
        
        self.readSwitch.tintColor = primaryColour
        
    }
    
    func setUpButtons() {
        
        self.termsButton.setTitle("View Terms & Conditions ", for: UIControlState())
        self.termsButton.tintColor = primaryColour
        
        self.acceptButton.setTitle("Accept & Continue", for: UIControlState())
        self.acceptButton.layer.backgroundColor = primaryColour.cgColor
        self.acceptButton.layer.cornerRadius = 2.5
        
    }
    
    func setUpLabels() {
        
        self.introLabel.numberOfLines = 0
        self.confirmLabel.numberOfLines = 0
        
        self.welcomeLabel.text = "Welcome to the BSE Toolbox!"
        
        self.introLabel.text = "Before you begin, you must review and accept the terms and conditions below.\nUse the slider to confirm that you have read, understand and accept the terms and conditions."
        
        self.confirmLabel.text = "I confirm that I have read, understand and accept the terms and conditions."
        
        
    }
}
