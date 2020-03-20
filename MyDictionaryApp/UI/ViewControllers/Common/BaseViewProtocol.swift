//
//  BaseViewProtocol.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 27.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

protocol BaseViewProtocol: class {
    
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
    
    func popViewController(animated: Bool)
    
    func showWaitScreen()
    
    func hideWaitScreen()
    
    func showAlertIn(withTitle title: String?, message: String,
                     firstButtonTitle: String?,
                     firstStyle: UIAlertAction.Style?,
                     otherButtonTitle: String?,
                     otherStyle: UIAlertAction.Style?,
                     tapBlock: UIAlertComplitionBlock?)
    
    func showAlertIn(withTitle title: String?, message: String, firstButtonTitle: String?, otherButtonTitle: String?, tapBlock: UIAlertComplitionBlock?)

}
