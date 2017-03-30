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


// MARK: - Water Pipe Sizer

// Loading units
var loadingUnits:[[Float]] = [[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float](),[Float]()]

// Reset the defaults to the built in defaults
func resetLoadingUnitDefaults() {
    
    loadingUnits = [[Float]]()
    loadingUnits.append([2,0,0,0])     // WC - Cold
    loadingUnits.append([0,0,0,2])     // WC - Rain
    loadingUnits.append([1,0,0,0])     // Urinal - Cold
    loadingUnits.append([0,0,0,1])     // Urinal - Rain
    loadingUnits.append([2,2,0,0])     // WHB - Cold & Hot
    loadingUnits.append([5,0,0,0])     // Sink - Cold
    loadingUnits.append([5,5,0,0])     // Sink - Cold & Hot
    loadingUnits.append([5,5,5,0])     // Sink - Cold & Hot & main
    loadingUnits.append([6,6,0,0])     // Shower - Cold & Hot
    loadingUnits.append([10,10,0,0])   // Bath - Cold & Hot
    loadingUnits.append([5,0,0,0])     // Tap - Cold
    loadingUnits.append([0,5,0,0])     // Tap - Hot
    loadingUnits.append([0,0,5,0])     // Tap - Mains
    loadingUnits.append([0,0,0,5])     // Tap - Rain
    
}

// Attempt to load the user specified loading Units, else load the built in defaults
func loadLoadingUnits() {
    
    let filePath = loadingUnitsFilePath()
    if (FileManager.default.fileExists(atPath: filePath)) {
        let array = NSArray(contentsOfFile: filePath) as! [[Float]]
        for i:Int in 0 ..< array.count {
            loadingUnits[i] = array[i]
        }
        print("Loading Units loaded from file")
    }
    else {
        resetLoadingUnitDefaults()
        print("Default Loading Units used")
    }
}


// Get the path to the defaults file
func loadingUnitsFilePath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0] as NSString
    return documentsDirectory.appendingPathComponent("loadingUnits.plist") as String
}



// MARK: - Duct Sizer

// Properties
var ductSizerProperties:[Float] = [Float(),Float(),Float()] // [rho, visco, k]

// Reset the defaults to the built in defaults
func resetDuctSizerPropertiesDefaults() {
    
    let visco:Float = 1.8178 * pow(10, -5)
    
    ductSizerProperties = [1.2041,visco, 0.075]
    
}

// Attempt to load the user specified properties, else load the built in defaults
func loadDuctSizerProperties() {
    
    let filePath = ductSizerPropertiesFilePath()
    if (FileManager.default.fileExists(atPath: filePath)) {
        let array = NSArray(contentsOfFile: filePath) as! [Float]
        for i:Int in 0 ..< array.count {
            ductSizerProperties[i] = array[i]
        }
        print("Duct Sizer Properties loaded from file")
    }
    else {
        resetDuctSizerPropertiesDefaults()
        print("Default Duct Sizer Properties used")
    }
}


// Get the path to the defaults file
func ductSizerPropertiesFilePath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0] as NSString
    return documentsDirectory.appendingPathComponent("ductSizerProperties.plist") as String
}




// MARK: - Pipe Sizer

// Properties (see defaults for each what each index represents)
var pipeSizerProperties:[Float] = [Float(),Float(),Float(),Float(),Float(),Float(),Float(),Float(),Float(),Float(),Float()]

// Reset the defaults to the built in defaults
func resetPipeSizerPropertiesDefaults() {
    
    // [max pa/m, k_steel, k_copper, C_lthw, rho_lthw, vis_lthw, dT_lthw, C_chw, rho_chw, vis_chw, dT_chw]
    resetMiscPipeDefaults()
    resetLPHWPipeDefaults()
    resetCHWPipeDefaults()
    
}

func resetMiscPipeDefaults() {
    pipeSizerProperties[0] = 250
    pipeSizerProperties[1] = 0.046
    pipeSizerProperties[2] = 0.0015
}

func resetLPHWPipeDefaults() {
    pipeSizerProperties[3] = 4.189
    pipeSizerProperties[4] = 977.8
    pipeSizerProperties[5] = 0.4091 * powf(10, -6)
    pipeSizerProperties[6] = 20
}

func resetCHWPipeDefaults() {
    pipeSizerProperties[7] = 3.8
    pipeSizerProperties[8] = 1000
    pipeSizerProperties[9] = 1.3004 * powf(10, -6)
    pipeSizerProperties[10] = 6
}

// Attempt to load the user specified properties, else load the built in defaults
func loadPipeSizerProperties() {
    
    let filePath = pipeSizerPropertiesFilePath()
    if (FileManager.default.fileExists(atPath: filePath)) {
        let array = NSArray(contentsOfFile: filePath) as! [Float]
        for i:Int in 0 ..< array.count {
            pipeSizerProperties[i] = array[i]
        }
        print("Pipe Sizer Properties loaded from file")
    }
    else {
        resetPipeSizerPropertiesDefaults()
        print("Default Pipe Sizer Properties used")
    }
}


// Get the path to the defaults file
func pipeSizerPropertiesFilePath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory,
        FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0] as NSString
    return documentsDirectory.appendingPathComponent("pipeSizerProperties.plist") as String
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
        header.contentView.backgroundColor = bdpColour
    }
    else {
        // Default Colour
        header.contentView.backgroundColor = primaryColour
    }
    
    return header
}


// MARK: - Colours
let bdpColour = UIColor(red: 205/255, green: 28/255, blue: 1/255, alpha: 1)
let colour = UIColor(red: 0/255, green: 153/255, blue: 204/255, alpha: 1.0)
let copperColour:UIColor = UIColor(red: 204/255, green: 102/255, blue: 0/255, alpha: 1)
let steelColour:UIColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
//let chwColour:UIColor = UIColor(red: 0/255, green: 153/255, blue: 255/255, alpha: 1)
let chwColour:UIColor = UIColor(red: 0/255, green: 51/255, blue: 204/255, alpha: 1)
let lphwColour:UIColor = UIColor(red: 251/255, green: 38/255, blue: 50/255, alpha: 1)

let primaryColour:UIColor = UIColor(red: 255/255, green: 93/255, blue: 83/255, alpha: 1)


