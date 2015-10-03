//
//  ParameterDetail.swift
//  Reef Journal
//
//  Created by Christopher Harding on 9/2/15
//  Copyright © 2015 Epic Kiwi Interactive
//

import Foundation

class ParameterDetail {
    let parameterType: Parameter
    var dataAccess: DataPersistence!


    init(parameter: Parameter) {
        self.parameterType = parameter
    }
}