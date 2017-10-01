//
//  Constants.swift
//  BDP Reference App
//
//  Created by Richard Seaman on 03/04/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation
import UIKit

let developerMode:Bool = true      // Used as a flag for logging extra info

extension String {
    
    // There are a number of text fields used to input floats
    // This extension makes it easier to convert between string and float
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

extension UIView {
    
    // Allows view border to be set in Storyboard
    // http://stackoverflow.com/questions/28854469/change-uibutton-bordercolor-in-storyboard
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

// The global calculator used for all tools
// must be initialised in App Delegate so that it loads on launch
var calculator:Calculator!

let APP_ID = 1118758962


// MARK: Rate on App Store

let daysBeforeAsking:Int = 2                        // number of days to wait before asking
let secondsBeforeAsking:Int = 120                   // how long the session must be before asking
var timeAtStart:Date = Date()                       // initialised from app delegate too

func okayToAskForRating() -> Bool {
    
    var okayToAsk = false
    
    let now:Date = Date()
    let userCalendar = Calendar.current
    var reason:String = ""
    
    if let lastAskedDate = loadRecordedFirstUseDate() {
        
        // Add the minimum number of days to the last asked date
        let earliestAskDate:Date = (userCalendar as NSCalendar).date(byAdding: .day,
                                                                     value: daysBeforeAsking,
                                                                     to: lastAskedDate,   // Date that it's added to
            options: [])!
        
        // Check if the access has expired
        if (now == (now as NSDate).laterDate(earliestAskDate)) {
            
            // It has passed the earliest ask date, so it's okay to ask again
            
            // Check if the session is long enough to ask yet
            let duration = Int(Date().timeIntervalSince(timeAtStart))
            if (duration >= secondsBeforeAsking) {
                okayToAsk = true
                reason = "Okay to ask, handing over to SKStoreReviewController..."
            } else {
                reason = "Session hasn't been active long enough (\(duration)s/\(secondsBeforeAsking)s have passed)"
            }
            
        } else {
            reason = "Not enough days passed since first use.\nMinimum Days to wait - \(daysBeforeAsking)."
        }
        
    }
    else {
        
        // If there's no saved first use date, it must be the first time it's being used (or the first time it's used since this was added)
        // save the current date as the first used date (we want to wait the minium number of days above before asking for the first time)
        saveFirstUsedDate(now)
        reason = "First time using app"
        
    }
    
    if developerMode {
        print("Called: checkIfOkayToAsk\nReturned: \(okayToAsk)\nReason: \(reason)")
    }
        
    
    return okayToAsk
    
}


// First Used Date Persistance
// Save the data
func saveFirstUsedDate(_ date:Date) {
    
    let filePath = dataFilePathForFirstUsedDate()
    
    // Deconstruct NSDate so it can be saved to plist (only care about year-month-day)
    
    let yearKey:String = "year"
    let monthKey:String = "month"
    let dayKey:String = "day"
    
    let userCalendar = Calendar.current
    
    let requestedDateComponents: NSCalendar.Unit = [.year, .month, .day]
    
    // Date components in the user's time zone
    let firstUseDateComponents = (userCalendar as NSCalendar).components(requestedDateComponents,
                                                                          from: date)
    
    let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
    //saving values
    dict.setObject(firstUseDateComponents.year ?? 2100, forKey: yearKey as NSCopying)  // includes a default future date
    dict.setObject(firstUseDateComponents.month ?? 1, forKey: monthKey as NSCopying)
    dict.setObject(firstUseDateComponents.day ?? 1, forKey: dayKey as NSCopying)
    
    if (dict.write(toFile: filePath, atomically: true)) {
        print("\nFirst Use Date saved to\n\(filePath)")
    }
    else {
        print("\nFirst Use Date could not be saved to\n\(filePath)")
    }
    
}

// Attempt to load the saved data
func loadRecordedFirstUseDate() -> Date? {
    
    let filePath = dataFilePathForFirstUsedDate()
    
    if (FileManager.default.fileExists(atPath: filePath)) {
        
        let dict = NSDictionary(contentsOfFile: filePath)
        
        // Reconstruct NSDate
        var firstUsedDate:Date? = nil
        
        let userCalendar = Calendar.current
        
        let yearKey:String = "year"
        let monthKey:String = "month"
        let dayKey:String = "day"
        
        var dateComponents = DateComponents()
        
        if let actualDict = dict {
            
            if let year = actualDict[yearKey] as? Int {
                
                if let month = actualDict[monthKey] as? Int {
                    
                    if let day = actualDict[dayKey] as? Int {
                        
                        dateComponents.year = year
                        dateComponents.month = month
                        dateComponents.day = day
                        
                        firstUsedDate = userCalendar.date(from: dateComponents)!
                        // print("\nFirst Used Date loaded from firstUsed.plist\(firstUsedDate?.description)\nMin Days To Wait: \(daysBeforeAsking)")
                        
                    }
                    
                }
                
            }
            
        }
        else {
            
            print("\nDictionary could not be extracted from - firstUsed.plist")
            
        }
        
        return firstUsedDate
        
    }
    else {
        print("\nLast Asked Date could not be loaded - firstUsed.plist does not exist @\n\(filePath)")
        return nil
    }
    
}

// Get the path to the file
func dataFilePathForFirstUsedDate() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0] as NSString
    return documentsDirectory.appendingPathComponent("firstUsed.plist") as String
}



// MARK: - Daylight Calculator

// Defaults for calculator = [ceiling, floor, walls, glass, transmittance, VSA, DCF]
var daylightCalculatorDefaults:[Float] = [Float(), Float(), Float(), Float(), Float(), Float(), Float()]

// Reset the defaults to the built in defaults
func resetDaylightDefaults() {
    resetDaylightRoomProperties()
    resetDaylightWindowProperties()
}

func resetDaylightRoomProperties() {
    
    daylightCalculatorDefaults[0] = 80
    daylightCalculatorDefaults[1] = 40
    daylightCalculatorDefaults[2] = 70
    daylightCalculatorDefaults[3] = 10
    
}

func resetDaylightWindowProperties() {
    
    daylightCalculatorDefaults[4] = 77
    daylightCalculatorDefaults[5] = 90
    daylightCalculatorDefaults[6] = 0.9
    
}

// Attempt to load the user specified defaults, else load the built in defaults
func loadDaylightDefaults() {
    
    let filePath = dataFilePath()
    if (FileManager.default.fileExists(atPath: filePath)) {
        let array = NSArray(contentsOfFile: filePath) as! [String]
        for i:Int in 0 ..< array.count {
            daylightCalculatorDefaults[i] = array[i].floatValue
        }
    }
    else {
        resetDaylightDefaults()
    }
    
    // print(daylightCalculatorDefaults)
}

// Get the path to the defaults file
func dataFilePath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0] as NSString
    return documentsDirectory.appendingPathComponent("defaults.plist") as String
}



// MARK: - Misc.

func getNavImageView(_ orientationToDisplayImageOn:UIInterfaceOrientation) -> UIImageView {
    
    // The navigation bar is shorter in landscape than portrait.
    // Change the size of the nav bar image so that it stays within the bar.
    
    var imageHeight:CGFloat = CGFloat()
    var imageWidth:CGFloat = CGFloat()
    
    if (orientationToDisplayImageOn == UIInterfaceOrientation.portrait) {
        imageHeight = 400/12
        imageWidth = 400/12
    }
    else {
        imageHeight = 400/16
        imageWidth = 400/16
    }
    
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageHeight, height: imageWidth))
    imageView.contentMode = .scaleAspectFit
    let image = UIImage(named: "navIcon")
    imageView.image = image
    
    if #available(iOS 11.0, *) {
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: imageWidth)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageHeight)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }
    
    return imageView
    
}

func getVersion() -> String {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return version
    }
    return "no version info"
}



func returnHeader(_ sender:UIView, colourOption option:Int = 0) -> UITableViewHeaderFooterView {
    
    let header: UITableViewHeaderFooterView = sender as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
    
    header.textLabel!.textColor = UIColor.white //make the text white
    
    header.alpha = 0.8 //make the header transparent
    /*
    if (option == 1) {
        // LPHW Colour
        header.contentView.backgroundColor = lphwColour
    }
    else if (option == 2) {
        // CHW Colour
        header.contentView.backgroundColor = chwColour
    }
    else if (option == 3) {
        // Gray Colour
        header.contentView.backgroundColor = UIColor.darkGray
    }
    else if (option == 4) {
        // Gray Colour
        header.contentView.backgroundColor = primaryColour
    }
    else {
        // Default Colour
        header.contentView.backgroundColor = primaryColour
    }*/
    header.contentView.backgroundColor = primaryColour
    return header
}

let defaultHeaderSizae:CGFloat = 28


// MARK: - Colours
let bdpColour = UIColor(red: 205/255, green: 28/255, blue: 1/255, alpha: 1)

let primaryColour:UIColor = UIColor(red: 255/255, green: 93/255, blue: 83/255, alpha: 1)


