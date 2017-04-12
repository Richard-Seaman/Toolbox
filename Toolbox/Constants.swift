//
//  Constants.swift
//  BDP Reference App
//
//  Created by Richard Seaman on 03/04/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import Foundation
import UIKit

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


