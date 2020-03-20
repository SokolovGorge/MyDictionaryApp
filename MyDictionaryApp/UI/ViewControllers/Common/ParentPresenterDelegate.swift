//
//  ParentPresenterDelegate.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 27.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation

@objc protocol ParentPresenterDelegate {
    
    @objc optional func onCommit(fromChild childPresenter: AnyObject, userInfo: Dictionary<String, Any>?)
    @objc optional func onCancel(fromChild childPresenter: AnyObject)
}
