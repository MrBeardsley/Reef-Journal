//
//  SettingsKey.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

enum SettingsKey: String {
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
    
    
    static var enabledParameterKeys: [SettingsKey] {
        get {
            return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium, .EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
        }
    }
    
    static var enabledChemistryKeys: [SettingsKey] {
        return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
    }
    
    static var enabledNutrientKeys: [SettingsKey] {
        return [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
    }
}


