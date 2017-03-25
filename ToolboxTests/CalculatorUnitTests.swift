//
//  CalculatorUnitTests.swift
//  Toolbox
//
//  Created by Richard Seaman on 21/03/2017.
//  Copyright © 2017 RichApps. All rights reserved.
//

import XCTest

class CalculatorUnitTests: XCTestCase {
    
    let calculator:Calculator = Calculator()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testSetValues() {
        
        // Cycle through a sample number of properties to set
        // Make sure that if they're set, the saved value is changed
        // Make sure if an invalid value is enetered, the value is not saved
        
        var newValue:Float = Float()
        var savedValue:Float = Float()
        
        // Pipe k value (Plastic)
        newValue = 0.05
        calculator.setKValue(duct: Calculator.DuctMaterial.Rect, kValue: newValue)
        savedValue = Calculator.DuctMaterial.Rect.kValue
        XCTAssert(newValue == savedValue)
        newValue = -0.05
        calculator.setKValue(duct: Calculator.DuctMaterial.Rect, kValue: newValue)
        savedValue = Calculator.DuctMaterial.Rect.kValue
        XCTAssert(newValue != savedValue)
        
        // Duct k value (Plastic)
        newValue = 0.05
        calculator.setKValue(pipe: Calculator.PipeMaterial.Plastic, kValue: newValue)
        savedValue = Calculator.PipeMaterial.Plastic.kValue
        XCTAssert(newValue == savedValue)
        newValue = -0.05
        calculator.setKValue(pipe: Calculator.PipeMaterial.Plastic, kValue: newValue)
        savedValue = Calculator.PipeMaterial.Plastic.kValue
        XCTAssert(newValue != savedValue)
        
        // Fluid specific heat capacity (LPHW)
        newValue = 4.17
        calculator.setSpecificHeatCapacity(fluid: Calculator.Fluid.LPHW, specificHeatCapacity: newValue)
        savedValue = Calculator.Fluid.LPHW.specificHeatCapacity
        XCTAssert(newValue == savedValue)
        newValue = -4.17
        calculator.setSpecificHeatCapacity(fluid: Calculator.Fluid.LPHW, specificHeatCapacity: newValue)
        savedValue = Calculator.Fluid.LPHW.specificHeatCapacity
        XCTAssert(newValue != savedValue)
        
        // Fluid viscosity (CHW)
        newValue = 0.4011 * powf(10, -6)
        calculator.setViscosity(fluid: Calculator.Fluid.CHW, visco: newValue)
        savedValue = Calculator.Fluid.CHW.visocity
        XCTAssert(newValue == savedValue)
        newValue = -0.4011 * powf(10, -6)
        calculator.setViscosity(fluid: Calculator.Fluid.CHW, visco: newValue)
        savedValue = Calculator.Fluid.CHW.visocity
        XCTAssert(newValue != savedValue)
        
        // Fluid density (MWS)
        newValue = 999
        calculator.setDensity(fluid: Calculator.Fluid.MWS, density: newValue)
        savedValue = Calculator.Fluid.MWS.density
        XCTAssert(newValue == savedValue)
        newValue = -999
        calculator.setDensity(fluid: Calculator.Fluid.MWS, density: newValue)
        savedValue = Calculator.Fluid.MWS.density
        XCTAssert(newValue != savedValue)
        
        // Fluid temperature difference - optional (CHW)
        newValue = 12
        calculator.setTemperatureDifference(fluid: Calculator.Fluid.CHW, dt: newValue)
        XCTAssert(newValue == Calculator.Fluid.CHW.temperatureDifference)
        newValue = -12
        calculator.setTemperatureDifference(fluid: Calculator.Fluid.CHW, dt: newValue)
        XCTAssert(newValue != Calculator.Fluid.CHW.temperatureDifference)
        
        // Fluid temperature difference for waters should be nil
        XCTAssert(Calculator.Fluid.MWS.temperatureDifference == nil)
        XCTAssert(Calculator.Fluid.CWS.temperatureDifference == nil)
        XCTAssert(Calculator.Fluid.HWS.temperatureDifference == nil)
        XCTAssert(Calculator.Fluid.RWS.temperatureDifference == nil)
        XCTAssert(Calculator.Fluid.Air.temperatureDifference == nil)
        
        // Fluid default max Pd (RWS)
        newValue = 200
        calculator.setMaxPd(fluid: Calculator.Fluid.RWS, maxPd: newValue)
        savedValue = Calculator.Fluid.RWS.maxPdDefault
        XCTAssert(newValue == savedValue)
        newValue = -200
        calculator.setMaxPd(fluid: Calculator.Fluid.RWS, maxPd: newValue)
        savedValue = Calculator.Fluid.RWS.maxPdDefault
        XCTAssert(newValue != savedValue)
        
        // Fluid default max Velocity (HWS)
        newValue = 5
        calculator.setMaxVelocity(fluid: Calculator.Fluid.HWS, maxVelocity: newValue)
        savedValue = Calculator.Fluid.HWS.maxVelocityDefault
        XCTAssert(newValue == savedValue)
        newValue = -5
        calculator.setMaxVelocity(fluid: Calculator.Fluid.HWS, maxVelocity: newValue)
        savedValue = Calculator.Fluid.HWS.maxVelocityDefault
        XCTAssert(newValue != savedValue)
        
    }
    
    func testResetDefaults() {
        
        // Run through a sample number of properties, set them as something different to the default
        // Then reset them to default and check that they are indeed the default value
        
        var newValue:Float = Float()
        var savedValue:Float = Float()
        
        // Test resetting individual properties
        
        // Save a new value
        newValue = 900
        calculator.setDensity(fluid: Calculator.Fluid.LPHW, density: newValue)
        // Reset the value
        calculator.resetSavedProperty(property: Calculator.SavedProperties.density_LPHW)
        // grab the saved value
        savedValue = Calculator.Fluid.LPHW.density
        // Check that the saved value is the default value
        XCTAssert(savedValue == Calculator.SavedProperties.density_LPHW.defaultValue)
        
        newValue = 4.8
        calculator.setSpecificHeatCapacity(fluid: .LPHW, specificHeatCapacity: newValue)
        calculator.resetSavedProperty(property: .c_LPHW)
        savedValue = Calculator.Fluid.LPHW.specificHeatCapacity
        XCTAssert(savedValue == Calculator.SavedProperties.c_LPHW.defaultValue)
        
        
        // Test resetting entire fluid properties
        
        // Save some new values
        calculator.setDensity(fluid: .LPHW, density: 500)
        calculator.setViscosity(fluid: .LPHW, visco: 0.3)
        calculator.setMaxVelocity(fluid: .LPHW, maxVelocity: 10)
        calculator.setTemperatureDifference(fluid: .LPHW, dt: 50)
        calculator.setMaxPd(fluid: .LPHW, maxPd: 1000)
        calculator.setSpecificHeatCapacity(fluid: .LPHW, specificHeatCapacity: 3.2)
        
        // Reset them
        calculator.resetDefaultFluidProperties(fluid: .LPHW)
        
        // Check they've been reset to the default values
        XCTAssert(Calculator.Fluid.LPHW.specificHeatCapacity == Calculator.SavedProperties.c_LPHW.defaultValue)
        XCTAssert(Calculator.Fluid.LPHW.density == Calculator.SavedProperties.density_LPHW.defaultValue)
        XCTAssert(Calculator.Fluid.LPHW.visocity == Calculator.SavedProperties.visco_LPHW.defaultValue)
        XCTAssert(Calculator.Fluid.LPHW.maxPdDefault == Calculator.SavedProperties.maxPd_LPHW.defaultValue)
        XCTAssert(Calculator.Fluid.LPHW.maxVelocityDefault == Calculator.SavedProperties.maxVelocity_LPHW.defaultValue)
        XCTAssert(Calculator.Fluid.LPHW.temperatureDifference == Calculator.SavedProperties.dt_LPHW.defaultValue)
        
        
        // Save some new values
        calculator.setDensity(fluid: .CHW, density: 500)
        calculator.setViscosity(fluid: .CHW, visco: 0.3)
        calculator.setMaxVelocity(fluid: .CHW, maxVelocity: 10)
        calculator.setTemperatureDifference(fluid: .CHW, dt: 50)
        calculator.setMaxPd(fluid: .CHW, maxPd: 1000)
        calculator.setSpecificHeatCapacity(fluid: .CHW, specificHeatCapacity: 3.2)
        
        // Reset them
        calculator.resetDefaultFluidProperties(fluid: .CHW)
        
        // Check they've been reset to the default values
        XCTAssert(Calculator.Fluid.CHW.specificHeatCapacity == Calculator.SavedProperties.c_CHW.defaultValue)
        XCTAssert(Calculator.Fluid.CHW.density == Calculator.SavedProperties.density_CHW.defaultValue)
        XCTAssert(Calculator.Fluid.CHW.visocity == Calculator.SavedProperties.visco_CHW.defaultValue)
        XCTAssert(Calculator.Fluid.CHW.maxPdDefault == Calculator.SavedProperties.maxPd_CHW.defaultValue)
        XCTAssert(Calculator.Fluid.CHW.maxVelocityDefault == Calculator.SavedProperties.maxVelocity_CHW.defaultValue)
        XCTAssert(Calculator.Fluid.CHW.temperatureDifference == Calculator.SavedProperties.dt_CHW.defaultValue)
        
        
        // Save some new values
        calculator.setDensity(fluid: .MWS, density: 500)
        calculator.setViscosity(fluid: .MWS, visco: 0.3)
        calculator.setMaxVelocity(fluid: .MWS, maxVelocity: 10)
        calculator.setTemperatureDifference(fluid: .MWS, dt: 50)
        calculator.setMaxPd(fluid: .MWS, maxPd: 1000)
        calculator.setSpecificHeatCapacity(fluid: .MWS, specificHeatCapacity: 3.2)
        
        // Reset them
        calculator.resetDefaultFluidProperties(fluid: .MWS)
        
        // Check they've been reset to the default values
        XCTAssert(Calculator.Fluid.MWS.specificHeatCapacity == Calculator.SavedProperties.c_MWS.defaultValue)
        XCTAssert(Calculator.Fluid.MWS.density == Calculator.SavedProperties.density_MWS.defaultValue)
        XCTAssert(Calculator.Fluid.MWS.visocity == Calculator.SavedProperties.visco_MWS.defaultValue)
        XCTAssert(Calculator.Fluid.MWS.maxPdDefault == Calculator.SavedProperties.maxPd_MWS.defaultValue)
        XCTAssert(Calculator.Fluid.MWS.maxVelocityDefault == Calculator.SavedProperties.maxVelocity_MWS.defaultValue)
        XCTAssert(Calculator.Fluid.MWS.temperatureDifference == nil)
        
        
        // Test resetting pipe properties
        
        // Save some new values
        calculator.setKValue(pipe: .Copper, kValue: 0.005)
        calculator.setKValue(pipe: .Plastic, kValue: 0.005)
        calculator.setKValue(pipe: .Steel, kValue: 0.005)
        
        // Reset them
        calculator.resetDefaultPipeProperties()
        calculator.resetDefaultDuctProperties()
        
        // Check they've been reset to the default values
        XCTAssert(Calculator.PipeMaterial.Copper.kValue == Calculator.SavedProperties.k_Copper.defaultValue)
        XCTAssert(Calculator.PipeMaterial.Plastic.kValue == Calculator.SavedProperties.k_Plastic.defaultValue)
        XCTAssert(Calculator.PipeMaterial.Steel.kValue == Calculator.SavedProperties.k_Steel.defaultValue)
        XCTAssert(Calculator.DuctMaterial.Rect.kValue == Calculator.SavedProperties.k_DuctRect.defaultValue)
        XCTAssert(Calculator.DuctMaterial.Circ.kValue == Calculator.SavedProperties.k_DuctCirc.defaultValue)
        
    }
    
    func testDuctSizer() {
        
        // Set the properties to use
        calculator.setKValue(duct: .Rect, kValue: 0.075)
        calculator.setKValue(duct: .Circ, kValue: 0.09)
        calculator.setDensity(fluid: .Air, density: 1.2041)
        calculator.setViscosity(fluid: .Air, visco: 1.8178 * pow(10, -5))
        
        
        // RECTANGULAR DUCTS
        
        // Check invalid parameters return nil
        XCTAssert(calculator.resultsForDuct(length: 500, width: 500, massFlowrate: -1, duct: .Rect, maxPd: 1, maxVelocity: 1,  aspect: 1) == nil)
        XCTAssert(calculator.resultsForDuct(length: 500, width: 500, massFlowrate: 1, duct: .Rect, maxPd: -1, maxVelocity: 1, aspect: 1) == nil)
        XCTAssert(calculator.resultsForDuct(length: 500, width: 500, massFlowrate: 1, duct: .Rect, maxPd: 1, maxVelocity: -1,aspect: 1) == nil)
        XCTAssert(calculator.resultsForDuct(length: -500, width: 500, massFlowrate: 1, duct: .Rect, maxPd: 1, maxVelocity: 1, aspect: 1) == nil)
        XCTAssert(calculator.resultsForDuct(length: 500, width: -500, massFlowrate: 1, duct: .Rect, maxPd: 1, maxVelocity: 1,aspect: 1) == nil)
        XCTAssert(calculator.resultsForDuct(length: 500, width: 500, massFlowrate: 1, duct: .Rect, maxPd: 1, maxVelocity: 1, aspect: -1) == nil)
        
        // Check against a number of known inputs and expected outputs
        // (see excel spreadsheet)
        
        if let result = calculator.resultsForDuct(length: 0.450, width: 0.250, volumeFlowrate: 0.9, duct: .Rect, maxPd: nil, maxVelocity: nil, aspect: nil) {
            
            XCTAssert(abs(result.pd - 2.1462406) < 0.001)
            XCTAssert(abs(result.v - 8.00) < 0.01)
            
        } else {
            // something went wrong
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: 0.450, width: 0.250, massFlowrate: 1.08369, duct: .Rect, maxPd: nil, maxVelocity: nil, aspect: nil) {
            
            XCTAssert(abs(result.pd - 2.1462406) < 0.001)
            XCTAssert(abs(result.v - 8.00) < 0.01)
        
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: 0.3, width: 0.9, massFlowrate: 2.16738, duct: .Rect, maxPd: nil, maxVelocity: nil, aspect: nil) {
            
            XCTAssert(abs(result.pd - 1.017) < 0.001)
            XCTAssert(abs(result.v - 6.667) < 0.01)
            XCTAssert(abs(result.aspect - 3) < 0.01)
            
        } else {
            XCTAssert(false)
        }
        
        
        if let result = calculator.resultsForDuct(length: nil, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1, maxVelocity: nil, aspect: nil) {
            
            XCTAssert(abs(result.length - 0.4) < 0.001)
            XCTAssert(abs(result.width - 0.4) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: nil, aspect: nil) {
            
            XCTAssert(abs(result.length - 0.4) < 0.001)
            XCTAssert(abs(result.width - 0.35) < 0.001)
            XCTAssert(abs(result.aspect - 1.142857143) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: nil, aspect: 2) {
            
            XCTAssert(abs(result.length - 0.6) < 0.001)
            XCTAssert(abs(result.width - 0.3) < 0.001)
            XCTAssert(abs(result.aspect - 2) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: 2.5,  aspect: nil) {
            
            XCTAssert(abs(result.length - 0.6) < 0.001)
            XCTAssert(abs(result.width - 0.6) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: 0.200, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: 5.5, aspect: nil) {
            
            XCTAssert(abs(result.length - 0.2) < 0.001)
            XCTAssert(abs(result.width - 0.85) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: 0.200,massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: 5.5,  aspect: nil) {
            
            XCTAssert(abs(result.length - 0.85) < 0.001)
            XCTAssert(abs(result.width - 0.2) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: 0.200, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: 5.5, aspect: 2) {
            
            XCTAssert(abs(result.length - 0.85) < 0.001)
            XCTAssert(abs(result.width - 0.2) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(length: nil, width: nil, massFlowrate: 1.08369, duct: .Rect, maxPd: 1.2, maxVelocity: 5.5, aspect: nil) {
            
            XCTAssert(abs(result.length - 0.45) < 0.001)
            XCTAssert(abs(result.width - 0.4) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        // CIRCULAR DUCTS
        
        // Check invalid parameters return nil
        XCTAssert(calculator.resultsForDuct(diameter: -0.25, massFlowrate: 1.08369, duct: .Circ, maxPd: 1, maxVelocity: 2.5) == nil)
        XCTAssert(calculator.resultsForDuct(diameter: 0.25, massFlowrate: -1.08369, duct: .Circ, maxPd: 1, maxVelocity: 2.5) == nil)
        XCTAssert(calculator.resultsForDuct(diameter: 0.25, massFlowrate: 1.08369, duct: .Circ, maxPd: -1, maxVelocity: 2.5) == nil)
        XCTAssert(calculator.resultsForDuct(diameter: 0.25, massFlowrate: 1.08369, duct: .Circ, maxPd: 1, maxVelocity: -2.5) == nil)
        
        // Check against a number of known inputs and expected outputs
        // (see excel spreadsheet)
        
        if let result = calculator.resultsForDuct(diameter: 0.25, volumeFlowrate: 0.9, duct: .Circ, maxPd: nil, maxVelocity: nil) {
            
            XCTAssert(abs(result.pd - 14.1355416) < 0.001)
            XCTAssert(abs(result.v - 18.33) < 0.01)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(diameter: 0.25, massFlowrate: 1.08369, duct: .Circ, maxPd: nil, maxVelocity: nil) {
            
            XCTAssert(abs(result.pd - 14.1355416) < 0.001)
            XCTAssert(abs(result.v - 18.33) < 0.01)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(diameter: 0.25, massFlowrate: 1.08369, duct: .Circ, maxPd: 0.5, maxVelocity: 0.5) {
            
            XCTAssert(abs(result.diameter - 0.25) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(diameter: nil, massFlowrate: 1.08369, duct: .Circ, maxPd: nil, maxVelocity: 2.5) {
            
            XCTAssert(abs(result.diameter - 0.7) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(diameter: nil, massFlowrate: 1.08369, duct: .Circ, maxPd: 1, maxVelocity: nil) {
            
            XCTAssert(abs(result.diameter - 0.45) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        if let result = calculator.resultsForDuct(diameter: nil, massFlowrate: 1.08369, duct: .Circ, maxPd: 0.5, maxVelocity: 4) {
            
            XCTAssert(abs(result.diameter - 0.55) < 0.001)
            
        } else {
            XCTAssert(false)
        }
        
        
        // Reset defaults
        calculator.resetDefaultDuctProperties()
        calculator.resetDefaultFluidProperties(fluid: .Air)
        
    }
    
    func testPipeSizer() {
        
        // Set the properties to use
        calculator.setKValue(pipe: .Steel, kValue: 0.046)
        calculator.setDensity(fluid: .LPHW, density: 977.8)
        calculator.setViscosity(fluid: .LPHW, visco: 0.4091 * powf(10, -6))
        calculator.setTemperatureDifference(fluid: .LPHW, dt: 20)
        calculator.setSpecificHeatCapacity(fluid: .LPHW, specificHeatCapacity: 4.189)
        
        // Test a 15mm steel pipe and compare against known results
        if let result = calculator.resultsForPipeSize(nominalDiameter: 15, massFlowrate: 0.2, material: .Steel, fluid: .LPHW) {
            
            // Grab the results and round them so we can compare
            let pd = round(result.pd, toNearest: 0.01)
            let v = round(result.v, toNearest: 0.01)
            
            XCTAssert(pd == 879.25)
            XCTAssert(v == 1.00)
            
        } else {
            XCTAssert(false)
        }
        
        // Test a 20mm steel pipe and compare against known results
        if let result = calculator.resultsForPipeSize(nominalDiameter: 20, massFlowrate: 0.2, material: .Steel, fluid: .LPHW) {
            
            // Grab the results and round them so we can compare
            let pd = round(result.pd, toNearest: 0.01)
            let v = round(result.v, toNearest: 0.01)
            
            XCTAssert(pd == 198.34)
            XCTAssert(v == 0.56)
            
        } else {
            XCTAssert(false)
        }
        
        // Test a nominal steel pipe size that doesn't exist
        if calculator.resultsForPipeSize(nominalDiameter: 34, massFlowrate: 0.2, material: .Steel, fluid: .LPHW) != nil {
            
            // There is no nominal size of 34 for a steel pipe so should return nil for results
            XCTAssert(false)
            
        } else {
            XCTAssert(true)
        }
        
        // Size a pipe base on maximum pressure only and compare against known results
        if let result = calculator.sizePipe(massFlowrate: 0.5, material: .Steel, fluid: .LPHW, maxPd: 250, maxVelocity: nil) {
            XCTAssert(result.nomDia == 32)
        }
        
        // Size a pipe base on maximum velcoity only and compare against known results
        if let result = calculator.sizePipe(massFlowrate: 0.5, material: .Steel, fluid: .LPHW, maxPd: nil, maxVelocity: 1) {
            XCTAssert(result.nomDia == 25)
        }
        
        // Size a pipe base on maximum velcoity only and compare against known results
        if let result = calculator.sizePipe(massFlowrate: 0.5, material: .Steel, fluid: .LPHW, maxPd: 250, maxVelocity: 1) {
            XCTAssert(result.nomDia == 32)
        }
        
        
        // Reset the default properties afterwards
        calculator.resetDefaultFluidProperties(fluid: .LPHW)
        calculator.resetDefaultPipeProperties()
        
    }
    
    
    // See link: http://www.globalnerdy.com/2016/01/26/better-to-be-roughly-right-than-precisely-wrong-rounding-numbers-with-swift/
    
    // round the value to the nearest multiple of that factor.
    func round(_ value: Float, toNearest: Float) -> Float {
        return roundf(value / toNearest) * toNearest
    }
    
    // Given a value to round and a factor to round to,
    // round the value DOWN to the largest previous multiple
    // of that factor.
    func roundDown(_ value: Float, toNearest: Float) -> Float {
        return floor(value / toNearest) * toNearest
    }
    
    // Given a value to round and a factor to round to,
    // round the value DOWN to the largest previous multiple
    // of that factor.
    func roundUp(_ value: Float, toNearest: Float) -> Float {
        return ceil(value / toNearest) * toNearest
    }
    
    
}
