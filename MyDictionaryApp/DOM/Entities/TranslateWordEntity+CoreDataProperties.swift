//
//  TranslateWordEntity+CoreDataProperties.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//
//

import Foundation
import CoreData


extension TranslateWordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslateWordEntity> {
        return NSFetchRequest<TranslateWordEntity>(entityName: "TranslateWordEntity")
    }

    @NSManaged public var index: Int16
    @NSManaged public var translate: String?
    @NSManaged public var native: NativeWordEntity?

}
