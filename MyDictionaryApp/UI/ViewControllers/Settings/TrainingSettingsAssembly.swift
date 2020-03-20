//
//  TrainingSettingsAssembly.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class TrainingSettingsAssembly: NSObject {
    
    @IBOutlet weak var controller: TrainingSettingsController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let router = TrainingSettingsRouterImp(controller: controller)
        let presenter = TrainingSettingsPresenterImp(view: controller, router: router)
        controller.presenter = presenter
    }
}
