//
//  NativeWordEntity+CoreDataProperties.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//
//

import Foundation
import CoreData


extension NativeWordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NativeWordEntity> {
        return NSFetchRequest<NativeWordEntity>(entityName: "NativeWordEntity")
    }

    @NSManaged public var associate: String?
    @NSManaged public var datecreate: Date?
    @NSManaged public var transcription: String?
    @NSManaged public var section: String?
    @NSManaged public var word: String?
    @NSManaged public var archive: Bool
    @NSManaged public var translates: NSSet?

}

// MARK: Generated accessors for translates
extension NativeWordEntity {

    @objc(addTranslatesObject:)
    @NSManaged public func addToTranslates(_ value: TranslateWordEntity)

    @objc(removeTranslatesObject:)
    @NSManaged public func removeFromTranslates(_ value: TranslateWordEntity)

    @objc(addTranslates:)
    @NSManaged public func addToTranslates(_ values: NSSet)

    @objc(removeTranslates:)
    @NSManaged public func removeFromTranslates(_ values: NSSet)

}
