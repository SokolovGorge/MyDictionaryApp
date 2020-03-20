//
//  NSManagedObjectContext+SBCoreStack.swift
//  CoreDataTest
//
//  Created by Соколов Георгий on 22.07.2018.
//  Copyright © 2018 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    static private var sbRootSavingContext: NSManagedObjectContext?
    static private var sbDefaultContext: NSManagedObjectContext?
    
    static var SB_DefaultContext: NSManagedObjectContext {
        get {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            guard let context = sbDefaultContext else {
                fatalError("Default contex not initialized")
            }
            return context
        }
    }
    
    static func SB_initializeStack(coordinator: NSPersistentStoreCoordinator) {
        if (sbDefaultContext != nil) {
            return
        }
        let rootContext = SB_context(coordinator: coordinator)
        SB_setRootSavingContext(context: rootContext)
        
        let defaultContext = SB_newMainQueueContext()
        SB_setDefaultContext(context: defaultContext)
        defaultContext.parent = rootContext
    }
    
    // MARK: Private Methods
    
    static private func SB_context(coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.performAndWait {
            context.persistentStoreCoordinator = coordinator
        }
        return context
    }
    
    static private func SB_newMainQueueContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        return context
    }
    
    static private func SB_setRootSavingContext(context: NSManagedObjectContext) {
        if let root = sbRootSavingContext {
            NotificationCenter.default.removeObserver(root)
        }
        sbRootSavingContext = context
        context.perform({
            context.SB_obtainPermanentIDsBeforeSaving()
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
        })
    }
    
    static private func SB_setDefaultContext(context: NSManagedObjectContext) {
        if let def = sbDefaultContext {
            NotificationCenter.default.removeObserver(def)
        }
        sbDefaultContext = context
        if let rootContext = sbRootSavingContext {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(SB_contextDidSave(notification:)),
                                                   name: Notification.Name.NSManagedObjectContextDidSave,
                                                   object: rootContext)
        }
        context.SB_obtainPermanentIDsBeforeSaving()
        
    }

    private func SB_obtainPermanentIDsBeforeSaving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SB_contextWillSave(notification:)),
                                               name: Notification.Name.NSManagedObjectContextWillSave,
                                               object: nil)
    }
    
    
    // MARK: - Notification handler
    
    @objc
    private func SB_contextWillSave(notification: Notification) {
        let context = notification.object as? NSManagedObjectContext
        if let context = context {
            let insertedObjects = context.insertedObjects
            if insertedObjects.count > 0 {
                do {
                    try context.obtainPermanentIDs(for: Array(insertedObjects))
                } catch {
                    print("Obtain error: \(error)")
                }
            }
        }
    }
    
    @objc
    private static func SB_contextDidSave(notification: Notification) {
        guard let currentContext = notification.object as? NSManagedObjectContext, currentContext === sbRootSavingContext else {
            return
        }
        
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                SB_contextDidSave(notification: notification)
            }
            return
        }
        if let dict = notification.userInfo as NSDictionary?, let objects = dict.object(forKey: NSUpdatedObjectsKey) as? [NSManagedObject] {
            for object in objects {
                sbDefaultContext?.object(with: object.objectID).willAccessValue(forKey: nil)
            }
        }
        sbDefaultContext?.mergeChanges(fromContextDidSave: notification)
    }
}
