//
//  Types.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

enum AppSettingsKey: String {
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
    
    
    static var enabledParameterKeys: [AppSettingsKey] {
        get {
            return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium, .EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
        }
    }
    
    static var enabledChemistryKeys: [AppSettingsKey] {
        return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
    }
    
    static var enabledNutrientKeys: [AppSettingsKey] {
        return [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
    }
}


