//
//  Types.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

enum Parameter: String {
    case Salinity
    case Temperature
    case Alkalinity
    case Calcium
    case Magnesium
    case pH
    case Strontium
    case Potasium
    case Ammonia
    case Nitrite
    case Nitrate
    case Phosphate
    
    static var allParameters: Set<Parameter> {
        return [.Salinity, .Temperature, .Alkalinity, .Calcium, .Magnesium, .pH, .Strontium, .Potasium, .Ammonia, .Nitrite, .Nitrate, .Phosphate]
    }
    
    static var chemistryParameters: Set<Parameter> {
        return [.Salinity, .Temperature, .Alkalinity, .Calcium, .Magnesium, .pH, .Strontium, .Potasium]
    }
    
    static var nutrientParameters: Set<Parameter> {
        return [.Ammonia, .Nitrite, .Nitrate, .Phosphate]
    }
}

enum SettingIdentifier: String {
    case TemperatureUnits
    case SalinityUnits
    case AlkalinityUnits
    case EnableTemperature
    case EnableSalinity
    case EnablePH
    case EnableAlkalinity
    case EnableCalcium
    case EnableMagnesium
    case EnableStrontium
    case EnablePotassium
    case EnableAmmonia
    case EnableNitrite
    case EnableNitrate
    case EnablePhosphate
    
    static var chemistrySettings: Set<SettingIdentifier> {
        return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
    }
    
    static var nutrientSettings: Set<SettingIdentifier> {
        return [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
    }
}

//let parameterList = [Parameter.Salinity.rawValue, Parameter.Temperature.rawValue, Parameter.Alkalinity.rawValue, Parameter.Calcium.rawValue, Parameter.Magnesium.rawValue, Parameter.pH.rawValue, Parameter.Strontium.rawValue, Parameter.Potasium.rawValue, Parameter.Ammonia.rawValue, Parameter.Nitrite.rawValue, Parameter.Nitrate.rawValue, Parameter.Phosphate.rawValue]

//let chemistryParameters: [SettingIdentifier] = [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
//
//let nutrientParameters: [SettingIdentifier] = [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]

//let parameterEnabledSettings = chemistryParameters + nutrientParameters

func parameterForPreference(preference: SettingIdentifier) -> Parameter {

    switch preference {
    case .TemperatureUnits: return Parameter.Temperature
    case .SalinityUnits: return Parameter.Salinity
    case .AlkalinityUnits: return Parameter.Alkalinity
    case .EnableTemperature: return Parameter.Temperature
    case .EnableSalinity: return Parameter.Salinity
    case .EnablePH: return Parameter.pH
    case .EnableAlkalinity: return Parameter.Alkalinity
    case .EnableCalcium: return Parameter.Calcium
    case .EnableMagnesium: return Parameter.Magnesium
    case .EnableStrontium: return Parameter.Strontium
    case .EnablePotassium: return Parameter.Potasium
    case .EnableAmmonia: return Parameter.Ammonia
    case .EnableNitrite: return Parameter.Nitrite
    case .EnableNitrate: return Parameter.Nitrate
    case .EnablePhosphate: return Parameter.Phosphate
    }
}
