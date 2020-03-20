//
//  EditWordAssembly.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 18.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class EditWordAssembly: NSObject {

    @IBOutlet weak var controller: EditWordController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let presenter = EditWordPresenterImp(view: controller)
        controller.presenter = presenter
        
    }
}
