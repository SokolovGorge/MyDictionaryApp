//
//  UIViewController+Alert.swift
//  SBSampleApp
//
//  Created by Соколов Георгий on 02.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showWaitScreen() {
        
    }
    
    func hideWaitScreen() {
        
    }
    
    func showAlertIn(withTitle title: String?, message: String,
                     firstButtonTitle: String?,
                     firstStyle: UIAlertAction.Style?,
                     otherButtonTitle: String?,
                     otherStyle: UIAlertAction.Style?,
                     tapBlock: UIAlertComplitionBlock?) {
        UIAlertController.showAlertIn(controller: self,
                                      withTitle: title,
                                      message: message,
                                      firstButtonTitle: firstButtonTitle,
                                      firstStyle: firstStyle,
                                      otherButtonTitle: otherButtonTitle,
                                      otherStyle: otherStyle,
                                      tapBlock: tapBlock)
    }
    
    func showAlertIn(withTitle title: String?, message: String, firstButtonTitle: String?, otherButtonTitle: String?, tapBlock: UIAlertComplitionBlock?) {
        UIAlertController.showAlertIn(controller: self,
                                      withTitle: title,
                                      message: message,
                                      firstButtonTitle: firstButtonTitle,
                                      otherButtonTitle: otherButtonTitle,
                                      tapBlock: tapBlock)
    }
    
    func popViewController(animated: Bool) {
        self.navigationController?.popViewController(animated: animated)
    }

}
