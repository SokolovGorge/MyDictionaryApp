//
//  DictionaryRouter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 13.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

protocol DictionaryRouter {
    
    func callEditWordController(with wordEntity: NativeWordEntity?)
    
}

class DictionaryRouterImp: DictionaryRouter {
    
    let controller: DictionaryController
    
    init(controller: DictionaryController) {
        self.controller = controller
    }
    
    func callEditWordController(with wordEntity: NativeWordEntity?) {
        let vc = R.storyboard.main.editWordController()
        vc?.wordEntity = wordEntity
        controller.navigationController?.pushViewController(vc!, animated: true)
//        let nc = UINavigationController(rootViewController: vc!)
//        controller.present(nc, animated: true)
    }
    
}
