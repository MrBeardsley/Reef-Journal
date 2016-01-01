//
//  Types.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/16/14
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

enum AppSettingKey: String {
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
    
    static var allParameterSettings: [AppSettingKey] {
        return self.chemistrySettings + self.nutrientSettings
    }
    
    static var chemistrySettings: [AppSettingKey] {
        return [.EnableTemperature, .EnableSalinity, .EnablePH, .EnableAlkalinity, .EnableCalcium, .EnableMagnesium, .EnableStrontium, .EnablePotassium]
    }
    
    static var nutrientSettings: [AppSettingKey] {
        return [.EnableAmmonia, .EnableNitrite, .EnableNitrate, .EnablePhosphate]
    }
}


