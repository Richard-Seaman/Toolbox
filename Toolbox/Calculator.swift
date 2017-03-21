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
    
    // This is initialised as the saved properties or the default values
    static private var properties:[Float] = [Float]()
    
    
    override init() {
        super.init()
        
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
        
        // Load the saved/ default properties
        loadProperties()
        
    }
    
    
    
    
    
    
    // MARK: Pipes
    
    enum PipeMaterial {
        
        // See CIBSE Guide C for Reference Data
        
        case Copper
        case Steel
        case Plastic
        
        var material: String {
            switch self {
            case .Copper:
                return "Copper"
            case .Steel:
                return "Steel"
            case .Plastic:
                return "Plastic"
            }
        }
        
        var kValue: Float {
            switch self {
            case .Copper:
                return properties[SavedProperties.k_Copper.index]
            case .Steel:
                return properties[SavedProperties.k_Steel.index]
            case .Plastic:
                return properties[SavedProperties.k_Plastic.index]
            }
        }
        
        var nominalDiameters: [Int] {
            switch self {
            case .Copper:
                return [15,22,28,35,42,54,67,76,108,133,159,219]
            case .Steel:
                return [15,20,25,32,40,50,65,80,90,100,125,150,200]
            case .Plastic:
                return [16,20,25,32,40,50,63,75,90,110,125,140,160,200,225,250,315]
            }
        }
        
        var internalDiameters: [Float] {
            switch self {
            case .Copper:
                return [0.0136,0.0202,0.0262,0.033,0.04,0.052,0.0643,0.0731,0.105,0.13,0.155,0.21]
            case .Steel:
                return [0.0161,0.0216,0.0274,0.036,0.0419,0.053,0.0687,0.0807,0.09315,0.1051,0.12995,0.1554,0.2191]
            case .Plastic:
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
    
    
    // MARK: Saved Properties
    
    enum SavedProperties {
        
        case maxPd_LPHW
        case maxPd_CHW
        case maxPd_MWS
        case maxPd_CWS
        case maxPd_HWS
        case maxPd_RWS
        case k_Steel
        case k_Copper
        case k_Plastic
        case c_LPHW
        case c_CHW
        case c_MWS
        case c_CWS
        case c_HWS
        case c_RWS
        case dt_LPHW
        case dt_CHW
        case visco_LPHW
        case visco_CHW
        case visco_MWS
        case visco_CWS
        case visco_HWS
        case visco_RWS
        case density_LPHW
        case density_CHW
        case density_MWS
        case density_CWS
        case density_HWS
        case density_RWS
        case maxVelocity_LPHW
        case maxVelocity_CHW
        case maxVelocity_MWS
        case maxVelocity_CWS
        case maxVelocity_HWS
        case maxVelocity_RWS
        
        // Create an array with all the types available
        // This allows us to cycle through them all (no in built way of doing this)
        
        static let all:[SavedProperties] = [
            maxPd_LPHW,maxPd_CHW,maxPd_MWS,maxPd_CWS,maxPd_HWS,maxPd_RWS,
            k_Steel,k_Copper,k_Plastic,
            c_LPHW,c_CHW,c_MWS,c_CWS,c_HWS,c_RWS,
            dt_LPHW,dt_CHW,visco_LPHW,visco_CHW,visco_MWS,visco_CWS,visco_HWS,visco_RWS,
            density_LPHW,density_CHW,density_MWS,density_CWS,density_HWS,density_RWS,
            maxVelocity_LPHW,maxVelocity_CHW,maxVelocity_HWS,maxVelocity_CWS,maxVelocity_HWS,maxVelocity_RWS]
        
        
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
            case .k_Steel:
                return 6
            case .k_Copper:
                return 7
            case .k_Plastic:
                return 8
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
            case .k_Steel:
                return 0.046
            case .k_Copper:
                return 0.0015
            case .k_Plastic:
                return 0.007
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
            case .k_Steel:
                return "k value for steel"
            case .k_Copper:
                return "k value for copper"
            case .k_Plastic:
                return "k value for plastic"
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
            }
        }
        
    }
    
    
    // MARK: Update Saved Properties
    
    func setKValue(pipe:PipeMaterial, kValue:Float) {
        
        // Update the appropriate value
        if (kValue > 0) {
            
            switch pipe {
            case .Plastic:
                Calculator.properties[SavedProperties.k_Plastic.index] = kValue
            case .Copper:
                Calculator.properties[SavedProperties.k_Copper.index] = kValue
            case .Steel:
                Calculator.properties[SavedProperties.k_Steel.index] = kValue
            }
            
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
            }
            
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
            }
            
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
            }
            
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
            }
            
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
            }
            
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
        case .CHW:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_CHW.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_CHW.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_CHW.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_CHW.defaultValue)
            setTemperatureDifference(fluid: fluid, dt: SavedProperties.dt_CHW.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_CHW.defaultValue)
        case .MWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_MWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_MWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_MWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_MWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_MWS.defaultValue)
        case .CWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_CWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_CWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_CWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_CWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_CWS.defaultValue)
        case .HWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_HWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_HWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_HWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_HWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_HWS.defaultValue)
        case .RWS:
            setSpecificHeatCapacity(fluid: fluid, specificHeatCapacity: SavedProperties.c_RWS.defaultValue)
            setDensity(fluid: fluid, density: SavedProperties.density_RWS.defaultValue)
            setMaxPd(fluid: fluid, maxPd: SavedProperties.maxPd_RWS.defaultValue)
            setMaxVelocity(fluid: fluid, maxVelocity: SavedProperties.maxVelocity_RWS.defaultValue)
            setViscosity(fluid: fluid, visco: SavedProperties.visco_RWS.defaultValue)
        }
        
        print("Properties reset to default for \(fluid.description)")
        
    }
    
    func resetDefaultPipeProperties() {
        
        // Reset all of the pipe k values
        
        setKValue(pipe: .Plastic, kValue: SavedProperties.k_Plastic.defaultValue)
        setKValue(pipe: .Copper, kValue: SavedProperties.k_Copper.defaultValue)
        setKValue(pipe: .Steel, kValue: SavedProperties.k_Steel.defaultValue)
        
        print("Pipe k values reset to default")
    }
    
    // MARK: Write / Read Properties from file
    
    private func loadProperties() {
        
        // NB: this must be only be called after the properties array has been created (with the correct size)
        
        // Grab the file path
        let pathForFile = filePath(fileName:propertiesFileName)
        
        // Load properties from saved file or create from defaults
        
        if (FileManager.default.fileExists(atPath: pathForFile)) {
            
            let array = NSArray(contentsOfFile: pathForFile) as! [Float]
            
            // For each entry in the properties array
            for i:Int in 0 ..< Calculator.properties.count {
                
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
        else {
            
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
            print("\nSaved Properties could not be written to file\n")
        }
    }
    
    private func filePath(fileName:String) -> String {
        
        // Get the file path from the file name
        // (it will be in the documents directory)
        
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.appendingPathComponent(fileName) as String
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
    
    private func resultsForPipe(massFlowrate:Float, fluid:Fluid, material:PipeMaterial) -> [(nomDia:Int, pd:Float, v:Float)]? {
        
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
    
    private func load(massFlowrate:Float, specificHeatCapacity:Float, temperatureDifference:Float) -> Float {
        return massFlowrate * specificHeatCapacity * temperatureDifference  // kW
    }
    
    private func massFlowrate(load:Float, specificHeatCapacity:Float, temperatureDifference:Float) -> Float {
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
        
        // Pd sub variables (formula is quite long)
        
        let a:Float = (6.9 * visco) / ( v * dia) + powf((k/1000) / (3.71 * dia), 1.11)
        
        let b:Float = -1.8 * log10(a)
        
        let c:Float = (0.5 * density * v * v) / dia
        
        
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
            print("mass flowrate = \(massFlowrate) kg/s")
            print("volume flowrate = \(q) m3/s")
            print("velocity = \(v) m/s")
            print("a = \(a)")
            print("b = \(b)")
            print("c = \(c)")
            print("Result:")
            print("Pressure Drop = \(pd) Pa/m")
            print("")
            
        }
        
        return pd   // Pa/m
        
    }
    
    
    // MARK: Misc


}
