//
//  LogBookVC.swift
//  Leaving Cert
//
//  Created by Richard Seaman on 09/05/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//


import UIKit

class FormulaeVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var filePath:URL = URL(fileURLWithPath: Bundle.main.path(forResource: "Formulae", ofType: "pdf")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the log book into the web views
        self.webView.loadRequest(URLRequest(url: filePath))
        
        // Prevent blank space appearing at top of webview
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)
        
        // Get rid of the back button text (get rid of "Back")
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        // Make sure the nav bar image fits within the new orientation
        self.checkOrientation(toInterfaceOrientation)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Make sure the nav bar image fits within the new orientation
        self.checkOrientation(UIApplication.shared.statusBarOrientation)
        
        // Google Analytics
        let name = "Formulae"
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
    }
    
    func checkOrientation(_ orientation:UIInterfaceOrientation) {
        
        // Make sure the nav bar image fits within the new orientation
        self.navigationItem.titleView = getNavImageView(orientation)
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        
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
    
    
    
}
