//
//  Calculator.swift
//  Toolbox
//
//  Created by Richard Seaman on 18/02/2017.
//  Copyright © 2017 RichApps. All rights reserved.
//

import UIKit

class Calculator: NSObject {
    
    // TODO: extract generic calulations to a single object
    
    let pi:Float = Float(M_PI)
    
    // File path for plist to save all of the properties to
    let propertiesFileName = "savedProperties.plist"
    let demandUnitsFileName = "demandUnits.plist"
    
    // This is initialised as the saved properties or the default values
    static private var properties:[Float] = [Float]()
    static private var demandUnits:[[Float]] = [[Float]]()
    
    
    override init() {
        super.init()
        
        print("Initialising Calculator")
        
        // SAVED PROPERTIES
        
        // Create an array of the correct length to hold the saved properties
        Calculator.properties = [Float]()
        
        // Find out what the largest index is
        var maxIndex:Int = 0
        for property:SavedProperties in SavedProperties.all {
            if property.index > maxIndex {
                maxIndex = property.index
            }
        }
        
        // Create an array that's big enough
        for _:Int in 0 ..< maxIndex + 1 {
            // Add an empty Float - just filling up the array with empty values so indexes won't cause a crash
            Calculator.properties.append(Float())
        }
        
        // Load the saved / default properties
        loadProperties()
        
        // SAVED DEMAND UNITS
        
        // Create an array of the correct length to hold the saved demand units
        Calculator.demandUnits = [[Float]]()
        
        // Find out what the largest index is
        maxIndex = 0
        for outlet:Outlets in Outlets.all {
            if outlet.savedIndex > maxIndex {
                maxIndex = outlet.savedIndex
            }
        }
        
        // Create an array that's big enough
        for _:Int in 0 ..< maxIndex + 1 {
            // Add an empty [Float] - just filling up the array with empty values so indexes won't cause a crash
            Calculator.demandUnits.append([Float]())
        }
        
        // Load the saved / default properties
        loadDemandUnits()
        
        print("Calculator ready to go!")
        
    }
    
    
    
    
    // MARK: Ducts
    
    enum DuctMaterial {
        
        // See CIBSE Guide C for Reference Data
        
        case Rect
        case Circ
        
        var material: String {
            switch self {
            case .Rect:
                return "rectangular ductwork"
            case .Circ:
                return "circular ductwork"
            }
        }
        
        var kValue: Float {
            switch self {
            case .Rect:
                return properties[SavedProperties.k_DuctRect.index]
            case .Circ:
                return properties[SavedProperties.k_DuctCirc.index]
            }
        }
        
        
    }

    
    // MARK: Pipes
    
    enum PipeMaterial {
        
        // See CIBSE Guide C for Reference Data
        
        case Copper
        case Steel
        case UPVC
        case ABS
        
        static let all:[PipeMaterial] = [.Copper, .Steel, .UPVC, .ABS]
        
        var material: String {
            switch self {
            case .Copper:
                return "Copper"
            case .Steel:
                return "Steel"
            case .UPVC:
                return "UPVC"
            case .ABS:
                return "ABS"
            }
        }
        
        var kValue: Float {
            switch self {
            case .Copper:
                return properties[SavedProperties.k_Copper.index]
            case .Steel:
                return properties[SavedProperties.k_Steel.index]
            case .UPVC:
                return properties[SavedProperties.k_Plastic.index]
            case .ABS:
                return properties[SavedProperties.k_Plastic.index]
            }
        }
        
        var colour: UIColor {
            // Used for the colour of the pipe view when selected in pipe sizer
            switch self {
            case .Copper:
                return UIColor(red: 204/255, green: 102/255, blue: 0/255, alpha: 1)
            case .Steel:
                return UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            case .UPVC:
                return UIColor.white
            case .ABS:
                return UIColor.black
            }
        }
        
        // NB: Each nominal diamter must have a corresponding internal diameter
        //     i.e. the arrays must be the same size for each material
        
        var nominalDiameters: [Int] {
            switch self {
            case .Copper:
                return [15,22,28,35,42,54,67,76,108,133,159,219]
            case .Steel:
                return [15,20,25,32,40,50,65,80,90,100,125,150,200]
            case .UPVC:
                return [16,20,25,32,40,50,63,75,90,110,125,140,160,180,200,225,250,280,315]
            case .ABS:
                return [16,20,25,32,40,50,63,75,90,110,125,140,160,200,225,250,315]
            }
        }
        
        var internalDiameters: [Float] {
            switch self {
            case .Copper:
                return [0.0136,0.0202,0.0262,0.033,0.04,0.052,0.0643,0.0731,0.105,0.13,0.155,0.21]
            case .Steel:
                return [0.0161,0.0216,0.0274,0.036,0.0419,0.053,0.0687,0.0807,0.09315,0.1051,0.12995,0.1554,0.2191]
            case .UPVC:
                return [0.013,0.017,0.022,0.0288,0.0362,0.0455,0.0570,0.0678,0.0814,0.1016,0.1154,0.1292,0.1476,0.1662,0.1846,0.2078,0.2308,0.2586,0.2908]
            case .ABS:
                return [0.013,0.0168,0.0212,0.0278,0.0346,0.0432,0.0546,0.065,0.078,0.0954,0.1086,0.1214,0.139,0.1736,0.1954,0.2178,0.2734]
            }
        }
        
    }
    
    func getInternalDiameterOfPipe(nominalDia:Int, material:PipeMaterial) -> Float? {
        
        if let index = material.nominalDiameters.index(of: nominalDia) {
            return material.internalDiameters[index]
        }
        return nil
    }
    
    func getNominalDiameterOfPipe(internalDia:Float, material:PipeMaterial) -> Int? {
        
        if let index = material.internalDiameters.index(of: internalDia) {
            return material.nominalDiameters[index]
        }
        return nil
        
    }
    
    
    // MARK: Fluids
    
    enum Fluid {
        
        case LPHW
        case CHW
        case CWS
        case HWS
        case MWS
        case RWS
        case Air
        
        var description: String {
            switch self {
            case .LPHW:
                return "Low Pressure Hot Water"
            case .CHW:
                return "Chilled Water"
            case .CWS:
                return "Cold Water Supply"
            case .HWS:
                return "Hot Water Supply"
            case .MWS:
                return "Mains Water Supply"
            case .RWS:
                return "Rain Water Supply"
            case .Air:
                return "Air"
            }
        }
        
        var abreviation: String {
            switch self {
            case .LPHW:
                return "LPHW"
            case .CHW:
                return "CHW"
            case .CWS:
                return "CWS"
            case .HWS:
                return "HWS"
            case .MWS:
                return "MWS"
            case .RWS:
                return "RWS"
            case .Air:
                return "Air"
            }
        }
        
        var colour: UIColor {
            // Colour of the fluid selection button when this fluid is selected
            switch self {
            case .LPHW:
                return UIColor(red: 210/255, green: 0/255, blue: 0/255, alpha: 1)
            case .CHW:
                return UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1)
            case .CWS:
                return UIColor(red: 0/255, green: 51/255, blue: 255/255, alpha: 1)
            case .HWS:
                return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            case .MWS:
                return UIColor(red: 0/255, green: 200/255, blue: 0/255, alpha: 1)
            case .RWS:
                return UIColor(red: 0/255, green: 204/255, blue: 204/255, alpha: 1)
            case .Air:
                return UIColor.white
            }
        }
        
        var specificHeatCapacity: Float {
            // kJ/kgK
            switch self {
            case .LPHW:
                return properties[SavedProperties.c_LPHW.index]
            case .CHW:
                return properties[SavedProperties.c_CHW.index]
            case .CWS:
                return properties[SavedProperties.c_CWS.index]
            case .HWS:
                return properties[SavedProperties.c_HWS.index]
            case .MWS:
                return properties[SavedProperties.c_MWS.index]
            case .RWS:
                return properties[SavedProperties.c_RWS.index]
            case .Air:
                return properties[SavedProperties.c_Air.index]
            }
        }
        
        var visocity: Float {
            // m2/s
            switch self {
            case .LPHW:
                return properties[SavedProperties.visco_LPHW.index]
            case .CHW:
                return properties[SavedProperties.visco_CHW.index]
            case .CWS:
                return properties[SavedProperties.visco_CWS.index]
            case .HWS:
                return properties[SavedProperties.visco_HWS.index]
            case .MWS:
                return properties[SavedProperties.visco_MWS.index]
            case .RWS:
                return properties[SavedProperties.visco_RWS.index]
            case .Air:
                return properties[SavedProperties.visco_Air.index]
            }
        }
        
        var density: Float {
            // kg/m3
            switch self {
            case .LPHW:
                return properties[SavedProperties.density_LPHW.index]
            case .CHW:
                return properties[SavedProperties.density_CHW.index]
            case .CWS:
                return properties[SavedProperties.density_CWS.index]
            case .HWS:
                return properties[SavedProperties.density_HWS.index]
            case .MWS:
                return properties[SavedProperties.density_MWS.index]
            case .RWS:
                return properties[SavedProperties.density_RWS.index]
            case .Air:
                return properties[SavedProperties.density_Air.index]
            }
        }
        
        var temperatureDifference: Float? {
            // C
            switch self {
            case .LPHW:
                return properties[SavedProperties.dt_LPHW.index]
            case .CHW:
                return properties[SavedProperties.dt_CHW.index]
            case .CWS:
                return nil
            case .HWS:
                return nil
            case .MWS:
                return nil
            case .RWS:
                return nil
            case .Air:
                return nil
            }
        }
        
        var maxPdDefault: Float {
            // Pa/m
            switch self {
            case .LPHW:
                return properties[SavedProperties.maxPd_LPHW.index]
            case .CHW:
                return properties[SavedProperties.maxPd_CHW.index]
            case .CWS:
                return properties[SavedProperties.maxPd_CWS.index]
            case .HWS:
                return properties[SavedProperties.maxPd_HWS.index]
            case .MWS:
                return properties[SavedProperties.maxPd_MWS.index]
            case .RWS:
                return properties[SavedProperties.maxPd_RWS.index]
            case .Air:
                return properties[SavedProperties.maxPd_Air.index]
            }
        }
        
        var maxVelocityDefault: Float {
            // m/s
            switch self {
            case .LPHW:
                return properties[SavedProperties.maxVelocity_LPHW.index]
            case .CHW:
                return properties[SavedProperties.maxVelocity_CHW.index]
            case .CWS:
                return properties[SavedProperties.maxVelocity_CWS.index]
            case .HWS:
                return properties[SavedProperties.maxVelocity_HWS.index]
            case .MWS:
                return properties[SavedProperties.maxVelocity_MWS.index]
            case .RWS:
                return properties[SavedProperties.maxVelocity_RWS.index]
            case .Air:
                return properties[SavedProperties.maxVelocity_Air.index]
            }
        }
        
        var pipeMaterial: PipeMaterial {
            
            // The saved property is actually the index of where the Pipe Material occurs in it's all array (saved as a Float)
            // We need to grab the saved property, convert it back to an Int and grab the associated PipeMaterial
            
            switch self {
            case .LPHW:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_LPHW.index])]
            case .CHW:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_CHW.index])]
            case .CWS:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_CWS.index])]
            case .HWS:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_HWS.index])]
            case .MWS:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_MWS.index])]
            case .RWS:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_RWS.index])]
            case .Air:
                return PipeMaterial.all[Int(properties[SavedProperties.pipeMaterialIndex_Air.index])]
            }
            
        }
        
    }
    
    
    // MARK: Units
    
    enum Units {
        
        case pressureDrop
        case velocity
        case diameter
        case viscosity
        case density
        case specificHeatCapacity
        
        var units: String{
            
            switch self {
            case .pressureDrop:
                return "Pa/m"
            case .velocity:
                return "m/s"
            case .diameter:
                return "m"
            case .viscosity:
                return "m2/s"
            case .density:
                return "kg/m3"
            case .specificHeatCapacity:
                return "kJ/kgK"
            }
            
        }
        
    }
    
    // MARK: Outlets
    
    enum Outlets {
        
        // A case for each combination of outlet and pipe arrangement
        // Eg. a WC may be served by either cold or rain water
        // Eg. A WHB may only be served by both hot and cold water
        
        // WC Options
        case WC_C       // Cold only
        case WC_R       // Rain only
        // Urinal Options
        case Urinal_C   // Cold only
        case Urinal_R   // Rain only
        // Wash Hand Basins Options
        case WHB_CH     // Cold & Hot
        // Sink Options
        case Sink_C     // Cold Only
        case Sink_CH    // Cold & Hot
        case Sink_CHM   // Cold & Hot & Mains
        // Shower Options
        case Shower_CH  // Cold & Hot
        // Bath Options
        case Bath_CH    // Cold & Hot
        // Tap Options
        case Tap_C      // Cold only
        case Tap_H      // Hot only
        case Tap_M      // Mains only
        case Tap_R      // Rain only
        
        // NB: If an outlet is added/removed this array must be updated!
        static let all:[Outlets] = [.WC_C, .WC_R,
                             .Urinal_C, Urinal_R,
                             .WHB_CH,
                             .Sink_C, .Sink_CH, .Sink_CHM,
                             .Shower_CH,
                             .Bath_CH,
                             .Tap_C, .Tap_H, .Tap_M, .Tap_R]
        
        // The fluids in each pipe
        // The index of which aligns with the demand unit indexes
        static let fluids:[Calculator.Fluid] = [.CWS, .HWS, .MWS, .RWS]
        
        
        var description: String {
            switch self {
            case .WC_C:
                return "WC - CWS"
            case .WC_R:
                return "WC - RWS"
            case .Urinal_C:
                return "Urinal - CWS"
            case .Urinal_R:
                return "Urinal - RWS"
            case .WHB_CH:
                return "WHB - CWS & HWS"
            case .Sink_C:
                return "Sink - CWS"
            case .Sink_CH:
                return "Sink - CWS & HWS"
            case .Sink_CHM:
                return "Sink - CWS & HWS & MWS"
            case .Shower_CH:
                return "Shower - CWS & HWS"
            case .Bath_CH:
                return "Bath - CWS & HWS"
            case .Tap_C:
                return "Tap - CWS"
            case .Tap_H:
                return "Tap - HWS"
            case .Tap_M:
                return "Tap - MWS"
            case .Tap_R:
                return "Tap - RWS"
            }
        }
        
        var pipeImage: UIImage {
            
            let pipe_C:UIImage = UIImage(named: "C")!
            let pipe_H:UIImage = UIImage(named: "H")!
            let pipe_M:UIImage = UIImage(named: "M")!
            let pipe_R:UIImage = UIImage(named: "R")!
            let pipe_CH:UIImage = UIImage(named: "CH")!
            let pipe_CHM:UIImage = UIImage(named: "CHM")!
            
            switch self {
            case .WC_C:
                return pipe_C
            case .WC_R:
                return pipe_R
            case .Urinal_C:
                return pipe_C
            case .Urinal_R:
                return pipe_R
            case .WHB_CH:
                return pipe_CH
            case .Sink_C:
                return pipe_C
            case .Sink_CH:
                return pipe_CH
            case .Sink_CHM:
                return pipe_CHM
            case .Shower_CH:
                return pipe_CH
            case .Bath_CH:
                return pipe_CH
            case .Tap_C:
                return pipe_C
            case .Tap_H:
                return pipe_H
            case .Tap_M:
                return pipe_M
            case .Tap_R:
                return pipe_R
            }
            
        }
        
        var outletImage:UIImage {
            
            let WC:UIImage = UIImage(named: "Toilet")!
            let urinal:UIImage = UIImage(named: "Urinal")!
            let WHB:UIImage = UIImage(named: "WHB")!
            let sink:UIImage = UIImage(named: "Sink")!
            let shower:UIImage = UIImage(named: "Shower")!
            let bath:UIImage = UIImage(named: "Bath")!
            let tap:UIImage = UIImage(named: "tap")!
            
            switch self {
            case .WC_C:
                return WC
            case .WC_R:
                return WC
            case .Urinal_C:
                return urinal
            case .Urinal_R:
                return urinal
            case .WHB_CH:
                return WHB
            case .Sink_C:
                return sink
            case .Sink_CH:
                return sink
            case .Sink_CHM:
                return sink
            case .Shower_CH:
                return shower
            case .Bath_CH:
                return bath
            case .Tap_C:
                return tap
            case .Tap_H:
                return tap
            case .Tap_M:
                return tap
            case .Tap_R:
                return tap
            }

        }
        
        var demandUnits:[Float] {
            if (self.savedIndex < Calculator.demandUnits.count) {
                return Calculator.demandUnits[self.savedIndex]
            } else {
                return self.defaultDemandUnits
            }
        }
        
        var defaultDemandUnits:[Float] {
            switch self {
            case .WC_C:
                return [2,0,0,0]
            case .WC_R:
                return [0,0,0,2]
            case .Urinal_C:
                return [1,0,0,0]
            case .Urinal_R:
                return [0,0,0,1]
            case .WHB_CH:
                return [2,2,0,0]
            case .Sink_C:
                return [5,0,0,0]
            case .Sink_CH:
                return [5,5,0,0]
            case .Sink_CHM:
                return [5,5,5,0]
            case .Shower_CH:
                return [6,6,0,0]
            case .Bath_CH:
                return [10,10,0,0]
            case .Tap_C:
                return [5,0,0,0]
            case .Tap_H:
                return [0,5,0,0]
            case .Tap_M:
                return [0,0,5,0]
            case .Tap_R:
                return [0,0,0,5]
            }
        }
        
        // Must explicitly state the index of each case instead of using the index within the "all" array above
        // This is required in case a new outlet is added in the middle of the all array
        // If we used the all array indexes to save/load the values, the indexes would no longer be aligned
        
        // NB: when adding new outlets, make sure the index is larger than the previous largest one
        var savedIndex:Int {
            switch self {
            case .WC_C:
                return 0
            case .WC_R:
                return 1
            case .Urinal_C:
                return 2
            case .Urinal_R:
                return 3
            case .WHB_CH:
                return 4
            case .Sink_C:
                return 5
            case .Sink_CH:
                return 6
            case .Sink_CHM:
                return 7
            case .Shower_CH:
                return 8
            case .Bath_CH:
                return 9
            case .Tap_C:
                return 10
            case .Tap_H:
                return 11
            case .Tap_M:
                return 12
            case .Tap_R:
                return 13
            }
        }
        
    }
    
    func setDemandUnits(outlet:Outlets, CWS_DU:Float, HWS_DU:Float, MWS_DU:Float, RWS_DU:Float) {
        
        // Check if there's an index for it
        if outlet.savedIndex < Calculator.demandUnits.count {
            
            // Make sure saved demand units are positive
            let cws:Float = CWS_DU >= 0 ? CWS_DU : 0
            let hws:Float = HWS_DU >= 0 ? HWS_DU : 0
            let mws:Float = MWS_DU >= 0 ? MWS_DU : 0
            let rws:Float = RWS_DU >= 0 ? RWS_DU : 0
            
            // Update the corresponding DU's
            Calculator.demandUnits[outlet.savedIndex] = [cws, hws, mws, rws]
            
            // Log it
            print("Updating demand units for \(outlet.description) to:")
            print("CWS - \(cws)")
            print("HWS - \(hws)")
            print("MWS - \(mws)")
            print("RWS - \(rws)")
            
            // Save the changes
            saveCurrentDemandUnits()
            
        } else {
            print("\nERROR:\nCould not update demand units for \(outlet.description) as it's saved index is out of range")
        }
        
    }
    
    
    
    // MARK: Saved Properties
    
    enum SavedProperties {
        
        // NB: If you add another case to SavedProperties make sure you add it to the all array [SavedProperties]
        
        // All Float values
        
        case maxPd_LPHW
        case maxPd_CHW
        case maxPd_MWS
        case maxPd_CWS
        case maxPd_HWS
        case maxPd_RWS
        case maxPd_Air
        case k_Steel
        case k_Copper
        case k_Plastic
        case k_DuctRect
        case k_DuctCirc
        case c_LPHW
        case c_CHW
        case c_MWS
        case c_CWS
        case c_HWS
        case c_RWS
        case c_Air
        case dt_LPHW
        case dt_CHW
        case visco_LPHW
        case visco_CHW
        case visco_MWS
        case visco_CWS
        case visco_HWS
        case visco_RWS
        case visco_Air
        case density_LPHW
        case density_CHW
        case density_MWS
        case density_CWS
        case density_HWS
        case density_RWS
        case density_Air
        case maxVelocity_LPHW
        case maxVelocity_CHW
        case maxVelocity_MWS
        case maxVelocity_CWS
        case maxVelocity_HWS
        case maxVelocity_RWS
        case maxVelocity_Air
        case pipeMaterialIndex_LPHW
        case pipeMaterialIndex_CHW
        case pipeMaterialIndex_MWS
        case pipeMaterialIndex_CWS
        case pipeMaterialIndex_HWS
        case pipeMaterialIndex_RWS
        case pipeMaterialIndex_Air
        
        // Create an array with all the types available
        // This allows us to cycle through them all (no in built way of doing this)
        
        static let all:[SavedProperties] = [
            maxPd_LPHW,maxPd_CHW,maxPd_MWS,maxPd_CWS,maxPd_HWS,maxPd_RWS,maxPd_Air,
            k_Steel,k_Copper,k_Plastic,k_DuctRect,k_DuctCirc,
            c_LPHW,c_CHW,c_MWS,c_CWS,c_HWS,c_RWS,c_Air,
            dt_LPHW,dt_CHW,visco_LPHW,visco_CHW,visco_MWS,visco_CWS,visco_HWS,visco_RWS,visco_Air,
            density_LPHW,density_CHW,density_MWS,density_CWS,density_HWS,density_RWS,density_Air,
            maxVelocity_LPHW,maxVelocity_CHW,maxVelocity_HWS,maxVelocity_CWS,maxVelocity_HWS,maxVelocity_RWS,maxVelocity_Air,
            pipeMaterialIndex_LPHW, pipeMaterialIndex_CHW, pipeMaterialIndex_MWS, pipeMaterialIndex_CWS, pipeMaterialIndex_HWS, pipeMaterialIndex_RWS, pipeMaterialIndex_Air]
        
        
        // NB: always add new properties to the end (later index) so existing saved files don't get confused
        
        var index: Int {
            switch self {
            case .maxPd_LPHW:
                return 0
            case .maxPd_CHW:
                return 1
            case .maxPd_MWS:
                return 2
            case .maxPd_CWS:
                return 3
            case .maxPd_HWS:
                return 4
            case .maxPd_RWS:
                return 5
            case .maxPd_Air:
                return 35
            case .k_Steel:
                return 6
            case .k_Copper:
                return 7
            case .k_Plastic:
                return 8
            case .k_DuctRect:
                return 40
            case .k_DuctCirc:
                return 41
            case .c_LPHW:
                return 9
            case .c_CHW:
                return 10
            case .c_MWS:
                return 11
            case .c_CWS:
                return 12
            case .c_HWS:
                return 13
            case .c_RWS:
                return 14
            case .c_Air:
                return 36
            case .dt_LPHW:
                return 15
            case .dt_CHW:
                return 16
            case .visco_LPHW:
                return 17
            case .visco_CHW:
                return 18
            case .visco_MWS:
                return 19
            case .visco_CWS:
                return 20
            case .visco_HWS:
                return 21
            case .visco_RWS:
                return 22
            case .visco_Air:
                return 37
            case .density_LPHW:
                return 23
            case .density_CHW:
                return 24
            case .density_MWS:
                return 25
            case .density_CWS:
                return 26
            case .density_HWS:
                return 27
            case .density_RWS:
                return 28
            case .density_Air:
                return 38
            case .maxVelocity_LPHW:
                return 29
            case .maxVelocity_CHW:
                return 30
            case .maxVelocity_MWS:
                return 31
            case .maxVelocity_CWS:
                return 32
            case .maxVelocity_HWS:
                return 33
            case .maxVelocity_RWS:
                return 34
            case .maxVelocity_Air:
                return 39
            case .pipeMaterialIndex_LPHW:
                return 42
            case .pipeMaterialIndex_CHW:
                return 43
            case .pipeMaterialIndex_CWS:
                return 44
            case .pipeMaterialIndex_HWS:
                return 45
            case .pipeMaterialIndex_MWS:
                return 46
            case .pipeMaterialIndex_RWS:
                return 47
            case .pipeMaterialIndex_Air:
                return 48
            }
        }
        
        
        var defaultValue: Float {
            switch self {
            case .maxPd_LPHW:
                return 250
            case .maxPd_CHW:
                return 250
            case .maxPd_MWS:
                return 250
            case .maxPd_CWS:
                return 250
            case .maxPd_HWS:
                return 250
            case .maxPd_RWS:
                return 250
            case .maxPd_Air:
                return 1
            case .k_Steel:
                return 0.046
            case .k_Copper:
                return 0.0015
            case .k_Plastic:
                return 0.007
            case .k_DuctRect:
                return 0.075    // based on galvanised steel
            case .k_DuctCirc:
                return 0.090    // based on spirally wound galvanised steel
            case .c_LPHW:
                return 4.18
            case .c_CHW:
                return 3.8
            case .c_MWS:
                return 4.18
            case .c_CWS:
                return 4.18
            case .c_HWS:
                return 4.18
            case .c_RWS:
                return 4.18
            case .c_Air:
                return 1.025
            case .dt_LPHW:
                return 20
            case .dt_CHW:
                return 6
            case .visco_LPHW:
                return 0.4091 * powf(10, -6)
            case .visco_CHW:
                return 1.3004 * powf(10, -6)
            case .visco_MWS:
                return 0.4091 * powf(10, -6)
            case .visco_CWS:
                return 0.4091 * powf(10, -6)
            case .visco_HWS:
                return 0.4091 * powf(10, -6)
            case .visco_RWS:
                return 0.4091 * powf(10, -6)
            case .visco_Air:
                return 1.8178 * pow(10, -5)
            case .density_LPHW:
                return 977.8
            case .density_CHW:
                return 1000
            case .density_MWS:
                return 1000
            case .density_CWS:
                return 1000
            case .density_HWS:
                return 1000
            case .density_RWS:
                return 1000
            case .density_Air:
                return 1.2041
            case .maxVelocity_LPHW:
                return 1.1
            case .maxVelocity_CHW:
                return 1.1
            case .maxVelocity_MWS:
                return 1.1
            case .maxVelocity_CWS:
                return 1.1
            case .maxVelocity_HWS:
                return 1.1
            case .maxVelocity_RWS:
                return 1.1
            case .maxVelocity_Air:
                return 2.5
            case .pipeMaterialIndex_LPHW:
                return Float(PipeMaterial.all.index(of: .Steel)!)       // Note only converting to FLoat so can use Saved Properties
            case .pipeMaterialIndex_CHW:
                return Float(PipeMaterial.all.index(of: .Steel)!)
            case .pipeMaterialIndex_CWS:
                return Float(PipeMaterial.all.index(of: .Copper)!)
            case .pipeMaterialIndex_HWS:
                return Float(PipeMaterial.all.index(of: .Copper)!)
            case .pipeMaterialIndex_MWS:
                return Float(PipeMaterial.all.index(of: .UPVC)!)
            case .pipeMaterialIndex_RWS:
                return Float(PipeMaterial.all.index(of: .Copper)!)
            case .pipeMaterialIndex_Air:
                return Float(PipeMaterial.all.index(of: .Copper)!)      // Doesn't matter, will return nil anyway
            }
            
        }
        
        
        var description: String {
            switch self {
            case .maxPd_LPHW:
                return "LPHW maximum pressure drop"
            case .maxPd_CHW:
                return "CHW maximum pressure drop"
            case .maxPd_MWS:
                return "MWS maximum pressure drop"
            case .maxPd_CWS:
                return "CWS maximum pressure drop"
            case .maxPd_HWS:
                return "HWS maximum pressure drop"
            case .maxPd_RWS:
                return "RWS maximum pressure drop"
            case .maxPd_Air:
                return "Air maximum pressure drop"
            case .k_Steel:
                return "k value for steel"
            case .k_Copper:
                return "k value for copper"
            case .k_Plastic:
                return "k value for plastic"
            case .k_DuctRect:
                return "k value for rectangular ductwork"
            case .k_DuctCirc:
                return "k value for circular ductwork"
            case .c_LPHW:
                return "LPHW specific heat capacity"
            case .c_CHW:
                return "CHW specific heat capacity"
            case .c_MWS:
                return "MWS specific heat capacity"
            case .c_CWS:
                return "CWS specific heat capacity"
            case .c_HWS:
                return "HWS specific heat capacity"
            case .c_RWS:
                return "RWS specific heat capacity"
            case .c_Air:
                return "Air specific heat capacity"
            case .dt_LPHW:
                return "LPHW flow & return temperature difference"
            case .dt_CHW:
                return "CHW flow & return temperature difference"
            case .visco_LPHW:
                return "LPHW kinematic viscosity"
            case .visco_CHW:
                return "CHW kinematic viscosity"
            case .visco_MWS:
                return "MWS kinematic viscosity"
            case .visco_CWS:
                return "CWS kinematic viscosity"
            case .visco_HWS:
                return "HWS kinematic viscosity"
            case .visco_RWS:
                return "RWS kinematic viscosity"
            case .visco_Air:
                return "Air kinematic viscosity"
            case .density_LPHW:
                return "LPHW density"
            case .density_CHW:
                return "CHW density"
            case .density_MWS:
                return "MWS density"
            case .density_CWS:
                return "CWS density"
            case .density_HWS:
                return "HWS density"
            case .density_RWS:
                return "RWS density"
            case .density_Air:
                return "Air density"
            case .maxVelocity_LPHW:
                return "LPHW maximum velocity"
            case .maxVelocity_CHW:
                return "CHW maximum velocity"
            case .maxVelocity_MWS:
                return "MWS maximum velocity"
            case .maxVelocity_CWS:
                return "CWS maximum velocity"
            case .maxVelocity_HWS:
                return "MWS maximum velocity"
            case .maxVelocity_RWS:
                return "RWS maximum velocity"
            case .maxVelocity_Air:
                return "Air maximum velocity"
            case .pipeMaterialIndex_LPHW:
                return "The default pipe material for LPHW"
            case .pipeMaterialIndex_CHW:
                return "The default pipe material for CHW"
            case .pipeMaterialIndex_CWS:
                return "The default pipe material for CWS"
            case .pipeMaterialIndex_HWS:
                return "The default pipe material for HWS"
            case .pipeMaterialIndex_MWS:
                return "The default pipe material for MWS"
            case .pipeMaterialIndex_RWS:
                return "The default pipe material for RWS"
            case .pipeMaterialIndex_Air:
                return "The default pipe material for Air"
            }
        }
        
    }
    
    
    // MARK: Update Saved Properties
    
    func setPipeMaterial(fluid:Fluid, material:PipeMaterial) {
        
        if let index = Calculator.PipeMaterial.all.index(of: material) {
            
            // Note: the saved property is the float value of the index of the material in the Pipe Material all array
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.pipeMaterialIndex_LPHW.index] = Float(index)
            case .CHW:
                Calculator.properties[SavedProperties.pipeMaterialIndex_CHW.index] = Float(index)
            case .MWS:
                Calculator.properties[SavedProperties.pipeMaterialIndex_MWS.index] = Float(index)
            case .CWS:
                Calculator.properties[SavedProperties.pipeMaterialIndex_CWS.index] = Float(index)
            case .HWS:
                Calculator.properties[SavedProperties.pipeMaterialIndex_HWS.index] = Float(index)
            case .RWS:
                Calculator.properties[SavedProperties.pipeMaterialIndex_RWS.index] = Float(index)
            case .Air:
                Calculator.properties[SavedProperties.pipeMaterialIndex_Air.index] = Float(index)
            }
            
            // Log it
            print("Setting Pipe Material of \(fluid.abreviation) to: \(material.material)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("Could not set pipe material for fluid, unknown pipe material enetered (make sure it's in the all array)")
            
        }
        
    }
    
    func setKValue(duct:DuctMaterial, kValue:Float) {
        
        // Update the appropriate value
        if (kValue > 0) {
            
            switch duct {
            case .Rect:
                Calculator.properties[SavedProperties.k_DuctRect.index] = kValue
            case .Circ:
                Calculator.properties[SavedProperties.k_DuctCirc.index] = kValue
            }
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("kValue must be greater than 0, no change made")
        }
        
    }
    
    func setKValue(pipe:PipeMaterial, kValue:Float) {
        
        // Update the appropriate value
        if (kValue > 0) {
            
            switch pipe {
            case .UPVC, .ABS:
                Calculator.properties[SavedProperties.k_Plastic.index] = kValue
            case .Copper:
                Calculator.properties[SavedProperties.k_Copper.index] = kValue
            case .Steel:
                Calculator.properties[SavedProperties.k_Steel.index] = kValue
            }
            
            // Log it
            print("Setting \(pipe.material) k value to: \(kValue)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("kValue must be greater than 0, no change made")
        }
        
    }
    
    func setSpecificHeatCapacity(fluid:Fluid, specificHeatCapacity:Float) {
        
        // Update the appropriate value
        if (specificHeatCapacity > 0) {
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.c_LPHW.index] = specificHeatCapacity
            case .CHW:
                Calculator.properties[SavedProperties.c_CHW.index] = specificHeatCapacity
            case .MWS:
                Calculator.properties[SavedProperties.c_MWS.index] = specificHeatCapacity
            case .CWS:
                Calculator.properties[SavedProperties.c_CWS.index] = specificHeatCapacity
            case .HWS:
                Calculator.properties[SavedProperties.c_HWS.index] = specificHeatCapacity
            case .RWS:
                Calculator.properties[SavedProperties.c_RWS.index] = specificHeatCapacity
            case .Air:
                Calculator.properties[SavedProperties.c_Air.index] = specificHeatCapacity
            }
            
            // Log it
            print("Setting Specific Heat Capacity of \(fluid.abreviation) to: \(specificHeatCapacity)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("specificHeatCapacity must be greater than 0, no change made")
        }
        
    }
    
    func setDensity(fluid:Fluid, density:Float) {
        
        // Update the appropriate value
        if (density > 0) {
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.density_LPHW.index] = density
            case .CHW:
                Calculator.properties[SavedProperties.density_CHW.index] = density
            case .MWS:
                Calculator.properties[SavedProperties.density_MWS.index] = density
            case .CWS:
                Calculator.properties[SavedProperties.density_CWS.index] = density
            case .HWS:
                Calculator.properties[SavedProperties.density_HWS.index] = density
            case .RWS:
                Calculator.properties[SavedProperties.density_RWS.index] = density
            case .Air:
                Calculator.properties[SavedProperties.density_Air.index] = density
            }
            
            // Log it
            print("Setting Density of \(fluid.abreviation) to: \(density)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("density must be greater than 0, no change made")
        }
        
    }
    
    func setViscosity(fluid:Fluid, visco:Float) {
        
        // Update the appropriate value
        if (visco > 0) {
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.visco_LPHW.index] = visco
            case .CHW:
                Calculator.properties[SavedProperties.visco_CHW.index] = visco
            case .MWS:
                Calculator.properties[SavedProperties.visco_MWS.index] = visco
            case .CWS:
                Calculator.properties[SavedProperties.visco_CWS.index] = visco
            case .HWS:
                Calculator.properties[SavedProperties.visco_HWS.index] = visco
            case .RWS:
                Calculator.properties[SavedProperties.visco_RWS.index] = visco
            case .Air:
                Calculator.properties[SavedProperties.visco_Air.index] = visco
            }
            
            // Log it
            print("Setting Viscosity of \(fluid.abreviation) to: \(visco)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("visco must be greater than 0, no change made")
        }
        
    }
    
    func setTemperatureDifference(fluid:Fluid, dt:Float) {
        
        // Update the appropriate value
        if (dt > 0) {
            
            var changeMade:Bool = true
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.dt_LPHW.index] = dt
            case .CHW:
                Calculator.properties[SavedProperties.dt_CHW.index] = dt
            default:
                print("No dT property for \(fluid.description)")
                changeMade = false
            }
            
            // Save the change
            if (changeMade) {
                
                // Log it
                print("Setting temperature differnce of \(fluid.abreviation) to: \(dt)")
                
                saveCurrentProperties()
            }
            
        } else {
            print("dt must be greater than 0, no change made")
        }
        
    }
    
    func setMaxPd(fluid:Fluid, maxPd:Float) {
        
        // Update the appropriate value
        if (maxPd > 0) {
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.maxPd_LPHW.index] = maxPd
            case .CHW:
                Calculator.properties[SavedProperties.maxPd_CHW.index] = maxPd
            case .MWS:
                Calculator.properties[SavedProperties.maxPd_MWS.index] = maxPd
            case .CWS:
                Calculator.properties[SavedProperties.maxPd_CWS.index] = maxPd
            case .HWS:
                Calculator.properties[SavedProperties.maxPd_HWS.index] = maxPd
            case .RWS:
                Calculator.properties[SavedProperties.maxPd_RWS.index] = maxPd
            case .Air:
                Calculator.properties[SavedProperties.maxPd_Air.index] = maxPd
            }
            
            // Log it
            print("Setting maximum pressure drop of \(fluid.abreviation) to: \(maxPd)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("maxPd must be greater than 0, no change made")
        }
        
    }
    
    func setMaxVelocity(fluid:Fluid, maxVelocity:Float) {
        
        // Update the appropriate value
        if (maxVelocity > 0) {
            
            switch fluid {
            case .LPHW:
                Calculator.properties[SavedProperties.maxVelocity_LPHW.index] = maxVelocity
            case .CHW:
                Calculator.properties[SavedProperties.maxVelocity_CHW.index] = maxVelocity
            case .MWS:
                Calculator.properties[SavedProperties.maxVelocity_MWS.index] = maxVelocity
            case .CWS:
                Calculator.properties[SavedProperties.maxVelocity_CWS.index] = maxVelocity
            case .HWS:
                Calculator.properties[SavedProperties.maxVelocity_HWS.index] = maxVelocity
            case .RWS:
                Calculator.properties[SavedProperties.maxVelocity_RWS.index] = maxVelocity
            case .Air:
                Calculator.properties[SavedProperties.maxVelocity_Air.index] = maxVelocity
            }
            
            // Log it
            print("Setting maximum velocity of \(fluid.abreviation) to: \(maxVelocity)")
            
            // Save the change
            saveCurrentProperties()
            
        } else {
            print("maxVelocity must be greater than 0, no change made")
        }
        
    }
    
    func resetSavedProperty(property:SavedProperties) {
        // This resets the given property to it's default value
        Calculator.properties[property.index] = property.defaultValue
        saveCurrentProperties()
    }
    
    func resetDefaultFluidProperties(fluid:Fluid) {
        
        switch fluid {
        case .LPHW:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_LPHW.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_LPHW.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_LPHW.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_LPHW.defaultValue)
            setTemperatureDifference(fluid: fluid, dt: SavedProperties.dt_LPHW.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_LPHW.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_LPHW.defaultValue)])
        case .CHW:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_CHW.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_CHW.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_CHW.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_CHW.defaultValue)
            setTemperatureDifference(fluid: fluid, dt: SavedProperties.dt_CHW.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_CHW.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_CHW.defaultValue)])
        case .MWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_MWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_MWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_MWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_MWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_MWS.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_MWS.defaultValue)])
        case .CWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_CWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_CWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_CWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_CWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_CWS.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_CWS.defaultValue)])
        case .HWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_HWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_HWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_HWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_HWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_HWS.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_HWS.defaultValue)])
        case .RWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_RWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_RWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_RWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_RWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_RWS.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_RWS.defaultValue)])
        case .Air:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_Air.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_Air.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_Air.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_Air.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_Air.defaultValue)
            setPipeMaterial(fluid: fluid, material: PipeMaterial.all[Int(SavedProperties.pipeMaterialIndex_Air.defaultValue)])
        }
        
        print("Properties reset to default for \(fluid.description)")
        
    }
    
    func resetDefaultPipeProperties() {
        
        // Reset all of the pipe k values
        
        setKValue(pipe: .UPVC, kValue: SavedProperties.k_Plastic.defaultValue)
        setKValue(pipe: .Copper, kValue: SavedProperties.k_Copper.defaultValue)
        setKValue(pipe: .Steel, kValue: SavedProperties.k_Steel.defaultValue)
        
        print("Pipe k values reset to default")
    }
    
    func resetDefaultDuctProperties() {
        
        // Reset all of the pipe k values
        
        setKValue(duct: .Rect, kValue: SavedProperties.k_DuctRect.defaultValue)
        setKValue(duct: .Circ, kValue: SavedProperties.k_DuctCirc.defaultValue)
        
        print("Duct k values reset to default")
    }
    
    
    // MARK: Write / Read Properties from file
    
    private func loadProperties() {
        
        // NB: this must be only be called after the properties array has been created (with the correct size)
        
        // Grab the file path
        let pathForFile = filePath(fileName:propertiesFileName)
        
        // Track if we need to use the defaults or not
        var useDefault = true
        
        // Load properties from saved file or create from defaults
        
        if (FileManager.default.fileExists(atPath: pathForFile)) {
            
            if let array = NSArray(contentsOfFile: pathForFile) as? [Float] {
                
                // No need to use defaults as we successfully found a file and cast it to the expected array type
                useDefault = false
                
                // For each entry in the properties array
                for i:Int in 0 ..< Calculator.properties.count {
                    
                    // Track if any new properties (unsaved) have been found
                    var newPropertyDetected:Bool = false
                    
                    // Make sure there's a saved value before trying to cast it (there won't be if new properties have been added since the last save)
                    if i < array.count {
                        // Use the saved value
                        // Note: This assumes the indexes have not changed since the last save
                        //       Therefore it's very important that new properties that are added are assigned indexes greater than the existing ones
                        Calculator.properties[i] = array[i]
                    } else {
                        // No saved value available, use the default value
                        for property:SavedProperties in SavedProperties.all {
                            if (property.index == i) {
                                Calculator.properties[i] = property.defaultValue
                                print("No saved value for \(property.description), default value used")
                                newPropertyDetected = true
                                break
                            }
                            // if it's not found it will just be an empty Float()
                        }
                        
                    }
                    
                    // If a new property was added (an a default value assigned to it), save it to file
                    if (newPropertyDetected) {
                        saveCurrentProperties()
                    }
                    
                }
                print("Saved Properties loaded from file")
            }
            
            
        }
        
        if (useDefault) {
            
            // Populate the properties with the default values
            // we know that the calculator.properties has sufficient indexes as we already checked for the max index above
            for property:SavedProperties in SavedProperties.all {
                Calculator.properties[property.index] = property.defaultValue
            }
            
            // Save the properties
            saveCurrentProperties()
            
            print("Default Properties used")
        }

        
    }
    
    private func saveCurrentProperties() {
        
        // Save the current properties to file
        
        // Grab the file path
        let pathForFile = filePath(fileName:propertiesFileName)
        // Cast the array and write to file
        let array = Calculator.properties as NSArray
        if (array.write(toFile: pathForFile, atomically: true)) {
            print("Saved Properties saved Successfully")
        }
        else {
            print("\nERROR:\nSaved Properties could not be written to file\n")
        }
    }
    
    
    // MARK: Write / Read Demand units from file
    
    private func loadDemandUnits() {
        
        // NB: this must be only be called after the properties array has been created (with the correct size)
        
        // Grab the file path
        let pathForFile = filePath(fileName:demandUnitsFileName)
        
        // Track if we need to use the defaults or not
        var useDefault = true
        
        // Load properties from saved file or create from defaults
        
        if (FileManager.default.fileExists(atPath: pathForFile)) {
            
            if let array = NSArray(contentsOfFile: pathForFile) as? [[Float]] {
                
                // No need to use defaults as we successfully found a file and cast it to the expected array type
                useDefault = false
                
                // For each entry in the demand units array
                for i:Int in 0 ..< Calculator.demandUnits.count {
                    
                    // Track if any new outlets (unsaved) have been found
                    var newOutletDetected:Bool = false
                    
                    // Make sure there's a saved value before trying to cast it (there won't be if new outlets have been added since the last save)
                    if i < array.count {
                        // Use the saved value
                        // Note: This assumes the indexes have not changed since the last save
                        //       Therefore it's very important that new outlets that are added are assigned indexes greater than the existing ones
                        Calculator.demandUnits[i] = array[i]
                    } else {
                        // No saved value available, use the default value
                        for outlet:Outlets in Outlets.all {
                            if (outlet.savedIndex == i) {
                                Calculator.demandUnits[i] = outlet.defaultDemandUnits
                                print("No saved demand units for \(outlet.description), default value used")
                                newOutletDetected = true
                                break
                            }
                            // if it's not found it will just be an empty [Float]() (from init method)
                        }
                        
                    }
                    
                    // If a new outlet was added (and default demand units assigned to it), save it to file
                    if (newOutletDetected) {
                        saveCurrentDemandUnits()
                    }
                    
                }
                print("Saved Demand Units loaded from file")
            }
            else {
                
            }
            
            
        }
        
        if (useDefault) {
            
            // Populate the demand units with the default values
            // we know that the calculator.demandUnits has sufficient indexes as we already checked for the max index above (in init method)
            for outlet:Outlets in Outlets.all {
                Calculator.demandUnits[outlet.savedIndex] = outlet.defaultDemandUnits
            }
            
            // Save the properties
            saveCurrentDemandUnits()
            
            print("Default Demand Units used")
        }
        
        
    }
    
    private func saveCurrentDemandUnits() {
        
        // Save the current properties to file
        
        // Grab the file path
        let pathForFile = filePath(fileName:demandUnitsFileName)
        // Cast the array and write to file
        let array = Calculator.demandUnits as NSArray
        if (array.write(toFile: pathForFile, atomically: true)) {
            print("Demand Units saved Successfully")
        }
        else {
            print("\nERROR:\nDemand Units could not be written to file\n")
        }
    }
    
    // MARK: File Path (within Documents Directory)
    
    private func filePath(fileName:String) -> String {
        
        // Get the file path from the file name
        // (it will be in the documents directory)
        
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.appendingPathComponent(fileName) as String
    }
    
    
    // MARK: Simultaneous Demand Calculations
    
    // Set up demand unit vs flowrate array (used to interpolate a flowrate from a number of demand units)
    let demandUnitsLookUp:[Float] = [0, 3, 5, 10, 20, 30, 40, 50, 70, 100, 200, 800, 1000, 1500, 2000, 5000, 8000]
    let flowRatesLookUp:[Float] = [0, 0.15, 0.2, 0.3, 0.42, 0.55, 0.7, 0.8, 1, 1.25, 2.2, 6, 7, 9, 15, 20, 30]
    
    func resultsForSimDemand(fluid:Fluid, demandUnits:Float, additionalMassFlowrate:Float, material:PipeMaterial) -> (result:(nomDia:Int, massFlowrate:Float, velocity:Float, pd:Float)?, error:Int?, errorDesc:String?) {
        
        // This function attempts to size a pipe based on demand units and the given parameters
        // If an error occurs, the results returned are nil and an error code and description are also returned
        
        // Errors:
        // 0 = DU's are out of range, could not convert ot MFR
        // 1 = Could not size pipe for the given constraints
        
        var result: (nomDia:Int, massFlowrate:Float, velocity:Float, pd:Float)? = nil
        var error: Int? = nil
        var errorDesc: String? = nil
        
        // Convert the demand units to a mass flowrate
        if let mfr:Float = self.convertDemandUnitToFlowrate(demandUnits: demandUnits) {
            
            // Remember to include the additional flowrate (if any)
            // Make sure the additional flowrate is positive
            let extraFlow:Float = additionalMassFlowrate >= 0 ? additionalMassFlowrate : 0
            
            // Size the pipe based on the default max pd and max v
            // if there's no result it will still be nil
            if let pipeResult = sizePipe(massFlowrate: mfr + extraFlow, material: material, fluid: fluid, maxPd: fluid.maxPdDefault, maxVelocity: fluid.maxVelocityDefault) {
                
                result = (nomDia:pipeResult.nomDia, massFlowrate:mfr + extraFlow, velocity:pipeResult.v, pd:pipeResult.pd)
                
            } else {
                print("")
                print("Pipe could not be sized based on the following parameters:")
                print("MFR: \(mfr) kg/s")
                print("maxpd: \(fluid.maxPdDefault) Pa/m")
                print("maxV: \(fluid.maxVelocityDefault) m/s")
                print("Material: \(material.material)")
                print("Fluid: \(fluid.description)")
                print("Setting resultsForSimDemand = nil")
                print("")
                error = 1
                errorDesc = "Could not size pipe for the given constraints"
            }
            
        } else {
            error = 0
            errorDesc = "DU's are out of range, could not convert ot MFR"
        }
        
        return (result, error, errorDesc)
    }
    
    func convertDemandUnitToFlowrate(demandUnits:Float) -> Float? {
        
        // Make sure demandunits used to interpolate are > 0
        let du:Float = demandUnits > 0 ? demandUnits : 0
        
        // Interpolate the flowrate from the demand units
        for index:Int in 0..<self.demandUnitsLookUp.count {
            
            if (du >= self.demandUnitsLookUp.last!) {
                // If it's out of range
                print("\nFlowrate out of range for given demand units, returning nil")
                
            }
            else if (self.demandUnitsLookUp[index] <= du  && self.demandUnitsLookUp[index+1] > du ) {
                
                // The total demand lies between these two values, interpolate between them
                return  ((du - self.demandUnitsLookUp[index]) / (self.demandUnitsLookUp[index+1] - self.demandUnitsLookUp[index]) ) * (self.flowRatesLookUp[index+1] - self.flowRatesLookUp[index]) + self.flowRatesLookUp[index]
                
            }
            
        }
        
        // If we get here, then the interpolation failed for some reason, so return nil
        // Most likely because the du's are out of range
        return  nil
        
    }
    
    // MARK: Duct Sizer Calculations
    
    let ductDimensionIncrement:Float = 50 / 1000    // must be in m
    
    // Rectangular
    // Two options for VFR or MFR
    
    func resultsForDuct(length:Float?, width:Float?, volumeFlowrate:Float, duct:DuctMaterial, maxPd:Float?, maxVelocity:Float?, aspect:Float?) -> (length:Float, width:Float, aspect:Float, pd:Float, v:Float)? {
        
        // NB: be careful with units
        // volumeFlowrate           m3/s
        // See below for remainder
        
        let mfr:Float = massFlowrate(volumeFlowrate: volumeFlowrate, density: Fluid.Air.density)
        return resultsForDuct(length: length, width: width, massFlowrate: mfr, duct: duct, maxPd: maxPd, maxVelocity: maxVelocity, aspect: aspect)
    }
    
    func resultsForDuct(length:Float?, width:Float?, massFlowrate:Float, duct:DuctMaterial, maxPd:Float?, maxVelocity:Float?, aspect:Float?) -> (length:Float, width:Float, aspect:Float, pd:Float, v:Float)? {
        
        // NB: be careful with units
        // length           m
        // width            m
        // massFlowrate     kg/s
        // maxPd            Pa/m  
        // maxVelocity      m/s
        // aspect           -       (length:width)
        
        // Air is assumed to be the fluid for duct sizing
        
        // If both length and width are provided, results will be calculated for the given size (and constraints ignored)
        // If either length or width are provided (but not both), then the given dimension is locked and the other dimension is sized based on the given constraints
        // If the length and width are not provided, the duct will be sized on the given constraints (including the given aspect ratio)
        // if there are no constraints the results for the minimum size will be provided
        // when sizing the ducts, the dimesnions that can be altered are incremented by the ductDimensionIncrement above
        
        // Check inputs
        
        if (massFlowrate < 0) {
            print("massflowrate must be > 0 to size duct")
            return nil
        }
        
        if (maxPd != nil) {
            if (maxPd! < 0) {
                print("If a maxPd is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (maxVelocity != nil) {
            if (maxVelocity! < 0) {
                print("If a maxVelocity is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (length != nil) {
            if (length! < 0) {
                print("If a length is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (width != nil) {
            if (width! < 0) {
                print("If a length is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (aspect != nil) {
            if (aspect! < 0) {
                print("If an aspect is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (length != nil && width != nil) {
            
            // Both dimensions have been specified
            // Just grab the results (and ignore the maxPd and maxVel constraints)
            
            let pressureDrop = pd(massFlowrate: massFlowrate, length: length!, width: width!, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            let velocity = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: length!, width: width!)
            
            var aspt = length!/width!
            if (aspt < 1) {
                aspt = width! / length!
            }
            
            return (length:length!, width:width!, aspect:aspt,pd:pressureDrop,v:velocity)
            
        } else if (length == nil && width == nil) {
            
            // if both are nil, both can be altered
            var widthToUse = ductDimensionIncrement
            var lengthToUse = ductDimensionIncrement
            if let actualAspect = aspect {
                 lengthToUse = widthToUse * actualAspect
            }
            
            // Initial calcs
            var actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            var actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
            
            if (maxPd == nil && maxVelocity == nil) {
                
                // No contraints provided, no need to do anymore, will just return initial values
                
            } else {
                
                // At least one constraint provided
                var lengthLastIncremented:Bool = false
                
                if (maxPd != nil && maxVelocity != nil) {
                    
                    // Both constraints provided, size to both
                    while (actualPd >= maxPd! || actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        
                        // if the aspect is defined, we have to use that
                        if let actualAspect = aspect {
                            widthToUse = widthToUse + ductDimensionIncrement
                            lengthToUse = widthToUse * actualAspect
                        } else {
                            
                            // if the aspect isn't defined, take it in turns to increment each duct dimension
                            if (lengthLastIncremented) {
                                widthToUse = widthToUse + ductDimensionIncrement
                                lengthLastIncremented = false
                            } else {
                                lengthToUse = lengthToUse + ductDimensionIncrement
                                lengthLastIncremented = true
                            }
                        }
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                    
                } else if (maxPd != nil) {
                    
                    // Only a maximum Pd has been specified
                    while (actualPd >= maxPd!) {
                        
                        // Increment the duct size
                        
                        // if the aspect is defined, we have to use that
                        if let actualAspect = aspect {
                            widthToUse = widthToUse + ductDimensionIncrement
                            lengthToUse = widthToUse * actualAspect
                        } else {
                            
                            // if the aspect isn't defined, take it in turns to increment each duct dimension
                            if (lengthLastIncremented) {
                                widthToUse = widthToUse + ductDimensionIncrement
                                lengthLastIncremented = false
                            } else {
                                lengthToUse = lengthToUse + ductDimensionIncrement
                                lengthLastIncremented = true
                            }
                        }
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                } else {
                    
                    // Only a maximum velocity has been specified
                    while (actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        
                        // if the aspect is defined, we have to use that
                        if let actualAspect = aspect {
                            widthToUse = widthToUse + ductDimensionIncrement
                            lengthToUse = widthToUse * actualAspect
                        } else {
                            
                            // if the aspect isn't defined, take it in turns to increment each duct dimension
                            if (lengthLastIncremented) {
                                widthToUse = widthToUse + ductDimensionIncrement
                                lengthLastIncremented = false
                            } else {
                                lengthToUse = lengthToUse + ductDimensionIncrement
                                lengthLastIncremented = true
                            }
                        }
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                }
                
            }
            
            // Once we've got a big enough size
            
            // Calculate the new aspect
            var aspt = lengthToUse/widthToUse
            if (aspt < 1) {
                aspt = widthToUse / lengthToUse
            }
            
            // Return the results
            return (length:lengthToUse, width:widthToUse, aspect:aspt,pd:actualPd,v:actualVel)
            
        } else if (length == nil) {
            
            // width must not be nil or it would have been caught by if statement above
            // keep width contstant and change length as required
            
            let widthToUse = width!
            var lengthToUse = ductDimensionIncrement
            
            // Initial calcs
            var actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            var actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
            
            if (maxPd == nil && maxVelocity == nil) {
                
                // No contraints provided, no need to do anymore, will just return initial values
                
            } else {
                
                // At least one constraint provided
                
                if (maxPd != nil && maxVelocity != nil) {
                    
                    // Both constraints provided, size to both
                    while (actualPd >= maxPd! || actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        lengthToUse = lengthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                    
                } else if (maxPd != nil) {
                    
                    // Only a maximum Pd has been specified
                    while (actualPd >= maxPd!) {
                        
                        // Increment the duct size
                        lengthToUse = lengthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                } else {
                    
                    // Only a maximum velocity has been specified
                    while (actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        lengthToUse = lengthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                }
                
            }
            
            // Once we've got a big enough size
            
            // Calculate the new aspect
            var aspt = lengthToUse/widthToUse
            if (aspt < 1) {
                aspt = widthToUse / lengthToUse
            }
            
            // Return the results
            return (length:lengthToUse, width:widthToUse, aspect:aspt,pd:actualPd,v:actualVel)
            
        } else {
            
            // length must not be nil or it would have been caught by if statement above
            // keep length contstant and change width as required
            
            var widthToUse = ductDimensionIncrement
            let lengthToUse = length!
            
            // Initial calcs
            var actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            var actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
            
            if (maxPd == nil && maxVelocity == nil) {
                
                // No contraints provided, no need to do anymore, will just return initial values
                
            } else {
                
                // At least one constraint provided
                
                if (maxPd != nil && maxVelocity != nil) {
                    
                    // Both constraints provided, size to both
                    while (actualPd >= maxPd! || actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        widthToUse = widthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                    
                } else if (maxPd != nil) {
                    
                    // Only a maximum Pd has been specified
                    while (actualPd >= maxPd!) {
                        
                        // Increment the duct size
                        widthToUse = widthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                    
                } else {
                    
                    // Only a maximum velocity has been specified
                    while (actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        widthToUse = widthToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, length: lengthToUse, width: widthToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = rectangularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, length: lengthToUse, width: widthToUse)
                        
                    }
                }
                
            }
            
            // Once we've got a big enough size
            
            // Calculate the new aspect
            var aspt = lengthToUse/widthToUse
            if (aspt < 1) {
                aspt = widthToUse / lengthToUse
            }
            
            // Return the results
            return (length:lengthToUse, width:widthToUse, aspect:aspt,pd:actualPd,v:actualVel)
            
        }
        
    }
    
    
    // Circular
    // Two options for VFR or MFR
    
    func resultsForDuct(diameter:Float?, volumeFlowrate:Float, duct:DuctMaterial, maxPd:Float?, maxVelocity:Float?) -> (diameter:Float, pd:Float, v:Float)? {
        
        // NB: be careful with units
        // volumeFlowrate           m3/s
        // See below for remainder
        
        let mfr:Float = massFlowrate(volumeFlowrate: volumeFlowrate, density: Fluid.Air.density)
        return resultsForDuct(diameter: diameter, massFlowrate: mfr, duct: duct, maxPd: maxPd, maxVelocity: maxVelocity)
        
    }
    
    func resultsForDuct(diameter:Float?, massFlowrate:Float, duct:DuctMaterial, maxPd:Float?, maxVelocity:Float?) -> (diameter:Float, pd:Float, v:Float)? {
        
        // NB: be careful with units
        // diameter         m
        // massFlowrate     kg/s
        // maxPd            Pa/m
        // maxVelocity      m/s
        
        // Air is assumed to be the fluid for duct sizing
        
        // If the diameter is provided, then this is considered locked and can't be incremented, results will be calculated for the given size (and constraints ignored)
        // If the diamter is not provided, the duct will be sized on the given constraints 
        // if there are no constraints the results for the minimum size will be provided
        // when sizing the ducts, the dimesnions that can be altered are incremented by the ductDimensionIncrement above
        
        // Check inputs
        
        if (massFlowrate < 0) {
            print("massflowrate must be > 0 to size duct")
            return nil
        }
        
        if (maxPd != nil) {
            if (maxPd! < 0) {
                print("If a maxPd is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (maxVelocity != nil) {
            if (maxVelocity! < 0) {
                print("If a maxVelocity is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        if (diameter != nil) {
            if (diameter! < 0) {
                print("If a diameter is specified, it must be > 0 to size duct")
                return nil
            }
        }
        
        
        if (diameter != nil) {
            
            // Diameter has been specified
            // Just grab the results (and ignore the maxPd and maxVel constraints)
            
            let pressureDrop = pd(massFlowrate: massFlowrate, dia: diameter!, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            let velocity = circularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, dia: diameter!)
            
            
            return (diameter:diameter!,pd:pressureDrop,v:velocity)
            
        } else  {
            
            // No Diameter entered, size on constraints provided
            var diameterToUse = ductDimensionIncrement
            
            // Initial calcs
            var actualPd = pd(massFlowrate: massFlowrate, dia: diameterToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
            var actualVel = circularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, dia: diameterToUse)
            
            if (maxPd == nil && maxVelocity == nil) {
                
                // No contraints provided, no need to do anymore, will just return initial values
                
            } else {
                
                // At least one constraint provided
                
                if (maxPd != nil && maxVelocity != nil) {
                    
                    // Both constraints provided, size to both
                    while (actualPd >= maxPd! || actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        diameterToUse = diameterToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, dia: diameterToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = circularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, dia: diameterToUse)
                        
                    }
                    
                    
                } else if (maxPd != nil) {
                    
                    // Only a maximum Pd has been specified
                    while (actualPd >= maxPd!) {
                        
                        // Increment the duct size
                        diameterToUse = diameterToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, dia: diameterToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = circularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, dia: diameterToUse)
                        
                    }
                    
                } else {
                    
                    // Only a maximum velocity has been specified
                    while (actualVel >= maxVelocity!) {
                        
                        // Increment the duct size
                        diameterToUse = diameterToUse + ductDimensionIncrement
                        
                        // Recalculate
                        actualPd = pd(massFlowrate: massFlowrate, dia: diameterToUse, density: Fluid.Air.density, visco: Fluid.Air.visocity, k: duct.kValue, printCalc: false)
                        actualVel = circularVelocity(massFlowrate: massFlowrate, density: Fluid.Air.density, dia: diameterToUse)
                        
                    }
                }
                
            }
            
            // Once we've got a big enough size
            
            // Return the results
            return (diameter:diameterToUse, pd:actualPd, v:actualVel)
            
        }
       
    }
    
    
    
    
    // MARK: Pipe Sizer Calculations
    
    
    // Pipe size for given maximum pressure and/or velocity
    // Two options for MFR and VFR
    // The maxPd and maxVelocity are different to the default maxPd and maxVelocity of each fluid (which are more like placeholders)
    
    func sizePipe(volumeFlowrate:Float, material:PipeMaterial, fluid:Fluid, maxPd:Float?, maxVelocity:Float?) -> (nomDia:Int, pd:Float, v:Float)? {
        
        let MFR = massFlowrate(volumeFlowrate: volumeFlowrate, density: fluid.density)
        return sizePipe(massFlowrate: MFR, material: material, fluid: fluid, maxPd: maxPd, maxVelocity: maxVelocity)
        
    }
    
    func sizePipe(massFlowrate:Float, material:PipeMaterial, fluid:Fluid, maxPd:Float?, maxVelocity:Float?) -> (nomDia:Int, pd:Float, v:Float)? {
        
        // Can size pipe based on a maximum pressure drop, a maximum velocty, or both
        // But at leaste one is required
        if (maxPd == nil && maxVelocity == nil) {
            print("Calculator Error:")
            print("pipeSize returned nil as no maxPd or maxVel provided")
            print("")
            return nil
        }
        
        // Cycle through all available results (pipe sizes and corresponding Pd and V)
        if let results = resultsForPipe(massFlowrate: massFlowrate, fluid: fluid, material: material) {
            
            for result in results {
                
                // Sizing to both Pd and V
                if (maxPd != nil && maxVelocity != nil) {
                    if (result.pd <= maxPd! && result.v <= maxVelocity!) {
                        return result
                    }
                }
                
                // Sizing to Pd only
                else if (maxPd != nil) {
                    if (result.pd <= maxPd!) {
                        return result
                    }
                }
                
                // Sizing to Velocity only
                else if (maxVelocity != nil) {
                    if (result.v <= maxVelocity!) {
                        return result
                    }
                }
                
            }
            
        }
        
        // If we don't find any suitable pipe size for the given conditions, return nil
        return nil
        
    }
    
    
    // Results for a Specified Pipe NOMINAL Diameter
    // Two options, for MFR and VFR
    
    func resultsForPipeSize(nominalDiameter:Int, volumeFlowrate:Float, material:PipeMaterial, fluid:Fluid) -> (nomDia:Int, pd:Float, v:Float)? {
        
        let MFR = massFlowrate(volumeFlowrate: volumeFlowrate, density: fluid.density)
        return resultsForPipeSize(nominalDiameter: nominalDiameter, massFlowrate: MFR, material: material, fluid: fluid)
        
    }
    
    func resultsForPipeSize(nominalDiameter:Int, massFlowrate:Float, material:PipeMaterial, fluid:Fluid) -> (nomDia:Int, pd:Float, v:Float)? {
        
        // Check if the nominal diameter exists
        if let index = material.nominalDiameters.index(of: nominalDiameter) {
            
            let internalDiameter = material.internalDiameters[index]
            
            let velocity = circularVelocity(massFlowrate: massFlowrate, density: fluid.density, dia: internalDiameter)
            
            let pressureDrop = pd(massFlowrate: massFlowrate, dia: internalDiameter, density: fluid.density, visco: fluid.visocity, k: material.kValue, printCalc: false)
            
            return (nomDia:nominalDiameter, pd:pressureDrop, v:velocity)
            
        }
        
        print("Calculator Error:")
        print("Nominal pipe size \(nominalDiameter) does not exist for \(material.material) pipework")
        return nil
        
    }
    
    
    // Results for a Specified Pipe INTERNAL Diameter
    // Two options, for MFR and VFR
    
    func resultsForPipeSize(internalDiameter:Float, volumeFlowrate:Float, material:PipeMaterial, fluid:Fluid) -> (intDia:Float, pd:Float, v:Float) {
        
        let MFR = massFlowrate(volumeFlowrate: volumeFlowrate, density: fluid.density)
        return resultsForPipeSize(internalDiameter: internalDiameter, massFlowrate: MFR, material: material, fluid: fluid)
        
    }
    
    func resultsForPipeSize(internalDiameter:Float, massFlowrate:Float, material:PipeMaterial, fluid:Fluid) -> (intDia:Float, pd:Float, v:Float) {
        
        let velocity = circularVelocity(massFlowrate: massFlowrate, density: fluid.density, dia: internalDiameter)
        
        let pressureDrop = pd(massFlowrate: massFlowrate, dia: internalDiameter, density: fluid.density, visco: fluid.visocity, k: material.kValue, printCalc: false)
        
        return (intDia:internalDiameter, pd:pressureDrop, v:velocity)
        
    }
    
    
    // Calculate Pressure Drop and Velocity for all available pipes sizes for a given flowrate, material and fluid
    
    func resultsForPipe(massFlowrate:Float, fluid:Fluid, material:PipeMaterial) -> [(nomDia:Int, pd:Float, v:Float)]? {
        
        // Initialise a tuple
        var results = [(nomDia:Int, pd:Float, v:Float)]()
        
        // Cycle through all of the available pipe sizes for this material
        // Calculate the pressure drop and velocity for each
        for index:Int in 0..<material.internalDiameters.count {
            
            let internalDiamater = material.internalDiameters[index]
            let nominalDiameter = material.nominalDiameters[index]
            
            let velocity = circularVelocity(massFlowrate: massFlowrate, density: fluid.density, dia: internalDiamater)
            
            let pressureDrop = pd(massFlowrate: massFlowrate, dia: internalDiamater, density: fluid.density, visco: fluid.visocity, k: material.kValue, printCalc: false)
            
            let result = (nomDia:nominalDiameter, pd:pressureDrop, v:velocity)
            
            results.append(result)
            
        }
        
        
        if (results.count > 0) {
            return results
        }
        return nil
        
    }
    

    // MARK: Fundamental Calcs
    
    func load(massFlowrate:Float, specificHeatCapacity:Float, temperatureDifference:Float) -> Float {
        return massFlowrate * specificHeatCapacity * temperatureDifference  // kW
    }
    
    func massFlowrate(load:Float, specificHeatCapacity:Float, temperatureDifference:Float) -> Float {
        return load / (specificHeatCapacity * temperatureDifference)    // kg/s
    }
    
    private func massFlowrate(volumeFlowrate:Float, density:Float) -> Float {
        return volumeFlowrate * density     // kg/s
    }
    
    private func volumeFlowRate(massFlowrate:Float, density:Float) -> Float {
        return massFlowrate / density       // m3/s
    }
    
    private func circularVelocity(massFlowrate:Float, density:Float, dia:Float) -> Float {
        let VFR:Float = volumeFlowRate(massFlowrate: massFlowrate, density: density)
        return circularVelocity(volumeFlowrate: VFR, dia: dia)      // m/s
    }
    
    private func circularVelocity(volumeFlowrate:Float, dia:Float) -> Float {
        return (volumeFlowrate * 4) / (dia * dia * pi)  // m/s
    }
    
    private func rectangularVelocity(massFlowrate:Float, density:Float, length:Float, width:Float) -> Float {
        let VFR:Float = volumeFlowRate(massFlowrate: massFlowrate, density: density)
        return rectangularVelocity(volumeFlowrate: VFR, length: length, width: width)   // m/s
    }
    
    private func rectangularVelocity(volumeFlowrate:Float, length:Float, width:Float) -> Float {
        return volumeFlowrate / (length * width)    // m/s
    }
    
    private func equivalentDiameter(x:Float, y:Float) -> Float {
        return (2*x*y)/(x+y)    // m - Equivalent diameter
    }
    
    private func pd(massFlowrate:Float, dia:Float, density:Float, visco:Float, k:Float, printCalc:Bool) -> Float {
        
        // massFlowrate     kg/s
        // dia              m
        // density          kg/m3
        // visco            m2/s
        // k                /mm
        
        // Pd returned in Pa/m
        
        let q = volumeFlowRate(massFlowrate: massFlowrate, density: density)     // m3/s
        
        let v:Float  = self.circularVelocity(volumeFlowrate: q, dia: dia)   // m/s
        
        return pd(velocity: v, dia: dia, density: density, visco: visco, k: k, printCalc: printCalc) // Pa/m
        
    }
    
    private func pd(massFlowrate:Float, length:Float, width:Float, density:Float, visco:Float, k:Float, printCalc:Bool) -> Float {
        
        // massFlowrate     kg/s
        // length           m
        // width            m
        // density          kg/m3
        // visco            m2/s
        // k                /mm
        
        // Pd returned in Pa/m
        
        let q = volumeFlowRate(massFlowrate: massFlowrate, density: density)     // m3/s
        
        let v:Float  = self.rectangularVelocity(volumeFlowrate: q, length: length, width: width)   // m/s
        
        let dia:Float = self.equivalentDiameter(x: length, y: width)
        
        return pd(velocity: v, dia: dia, density: density, visco: visco, k: k, printCalc: printCalc) // Pa/m
        
    }
    
    private func pd(velocity:Float, dia:Float, density:Float, visco:Float, k:Float, printCalc:Bool) -> Float {
        
        // velocity         m/s
        // dia              m
        // density          kg/m3
        // visco            m2/s
        // k                /mm
        
        // Pd returned in Pa/m
        
        
        // Pd sub variables (formula is quite long)
        
        let a:Float = (6.9 * visco) / ( velocity * dia) + powf((k/1000) / (3.71 * dia), 1.11)
        
        let b:Float = -1.8 * log10(a)
        
        let c:Float = (0.5 * density * velocity * velocity) / dia
        
        
        // Pressure drop
        let pd = powf(1/b, 2) * c    // Pa/m
        
        // Print calc if required
        if (printCalc) {
            
            print("Properties used:")
            print("k = \(k) /mm")
            print("density = \(density) kg/m3")
            print("visco = \(visco) m2/s")
            
            print("Variables used to calculate pressure drop")
            print("int. d = \(dia) m")
            print("velocity = \(velocity) m/s")
            print("a = \(a)")
            print("b = \(b)")
            print("c = \(c)")
            print("Result:")
            print("Pressure Drop = \(pd) Pa/m")
            print("")
            
        }
        
        return pd   // Pa/m
        
    }
    
    


}
