//
//  TrainingAssembly.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 17.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class TrainingAssembly: NSObject {
    
    @IBOutlet weak var controller: TrainingController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let presenter = TrainingPresenterImp(view: controller)
        controller.presenter = presenter
    }

}
