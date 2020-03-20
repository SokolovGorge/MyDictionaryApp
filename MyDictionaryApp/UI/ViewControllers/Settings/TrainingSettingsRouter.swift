//
//  TrainingSettingsRouter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

protocol TrainingSettingsRouter {
    
}

class TrainingSettingsRouterImp: TrainingSettingsRouter {
    
    let controller: TrainingSettingsController
    
    init(controller: TrainingSettingsController) {
        self.controller = controller
    }
    
}
