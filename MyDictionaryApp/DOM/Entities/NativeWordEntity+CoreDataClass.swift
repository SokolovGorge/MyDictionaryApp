//
//  NativeWordEntity+CoreDataClass.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NativeWordEntity)
public class NativeWordEntity: NSManagedObject {
    
    static func className() -> String {
        return "NativeWordEntity"
    }
}
