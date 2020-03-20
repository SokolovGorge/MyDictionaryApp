//
//  UIAlertController+SBUtils.swift
//  SBSOFTVK
//
//  Created by Соколов Георгий on 11.11.2017.
//  Copyright © 2017 Соколов Георгий. All rights reserved.
//

import UIKit

enum SBAlertActionType {
    case first
    case other
}

typealias UIAlertComplitionBlock = (_ actionType: SBAlertActionType) -> Void

extension UIAlertController {
    
    class func showAlertIn(controller: UIViewController?,
                     withTitle title: String?,
                     message: String,
                     firstButtonTitle: String?,
                     firstStyle: UIAlertAction.Style?,
                     otherButtonTitle: String?,
                     otherStyle: UIAlertAction.Style?,
                     tapBlock: UIAlertComplitionBlock?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let firstButton = firstButtonTitle  {
            let actionStyle = firstStyle ?? .default
            let firstAction = UIAlertAction(title: firstButton, style: actionStyle, handler: { (action) in
                if let tapBlock = tapBlock {
                    tapBlock(.first)
                }
            })
            alertController.addAction(firstAction)
        }
        
        if let otherButton = otherButtonTitle {
            let actionStyle = otherStyle ?? .default
            let otherAction = UIAlertAction(title: otherButton, style: actionStyle, handler: { (action) in
                if let tapBlock = tapBlock {
                    tapBlock(.other)
                }
            })
            alertController.addAction(otherAction)
        }
        
        let realController = controller ?? UIApplication.shared.delegate!.window!?.rootViewController!
        realController!.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertIn(controller: UIViewController?,
                     withTitle title: String?,
                     message: String,
                     firstButtonTitle: String?,
                     otherButtonTitle: String?,
                     tapBlock: UIAlertComplitionBlock?) {
        
        showAlertIn(controller: controller,
                    withTitle: title,
                    message: message,
                    firstButtonTitle: firstButtonTitle,
                    firstStyle: .default,
                    otherButtonTitle: otherButtonTitle,
                    otherStyle: .default,
                    tapBlock: tapBlock)
    }
    
}
