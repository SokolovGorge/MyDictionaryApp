//
//  DictionaryAssembly.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 13.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class DictionaryAssembly: NSObject {
    
    @IBOutlet weak var controller: DictionaryController!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        let router = DictionaryRouterImp(controller: controller)
        let presenter = DictionaryPresenterImp(view: controller, router: router)
        controller.presenter = presenter
    }
    
}
