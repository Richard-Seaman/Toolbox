//
//  LaunchVC.swift
//  AstroApp
//
//  Created by Richard Seaman on 14/02/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//


// THIS VIEW NEVER APPEARS TO THE USER
// It simply acts as a navigation tool for the app, telling it where to begin.

import UIKit

class LaunchVC: UIViewController {
    
    @IBOutlet var background: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the background colour to the primary colour in case it flashes up for a split second
        self.background.backgroundColor = primaryColour
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        // Check if the user has accepted the T&Cs
        let prefs:UserDefaults = UserDefaults.standard
        let acceptedTerms:Int = prefs.integer(forKey: "ACCEPTEDTERMS") as Int
        
        
        // Determine which view to load
        if (acceptedTerms != 1) {
            self.performSegue(withIdentifier: "toTermsVC", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "toHomeVC", sender: self)
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}
