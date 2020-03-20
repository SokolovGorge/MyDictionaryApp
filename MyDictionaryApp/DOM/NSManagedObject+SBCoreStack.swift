//
//  NSManagedObject+SBCoreStack.swift
//  SBSampleApp
//
//  Created by Соколов Георгий on 15/01/2019.
//  Copyright © 2019 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData

enum ManagedObjectError: Error {
    case notContainContext
}

extension NSManagedObject {
    
    func object(inContext otherContext: NSManagedObjectContext) throws -> NSManagedObject {
        if self.objectID.isTemporaryID {
            if let currentContext = self.managedObjectContext {
                try currentContext.obtainPermanentIDs(for: [self])
            } else {
                throw ManagedObjectError.notContainContext
            }
        }
        return try otherContext.existingObject(with: self.objectID)
    }
}
