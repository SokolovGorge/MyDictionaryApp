//
//  SBCoreDataManager.swift
//  CoreDataTest
//
//  Created by Соколов Георгий on 22.07.2018.
//  Copyright © 2018 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData


class SBCoreDataManager: SBCoreDataService {    
    
    private static var _instance: SBCoreDataManager?
    
    private var modelName: String
    
    private var managedObjectModel: NSManagedObjectModel
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator
    private var rootContext: NSManagedObjectContext
    private var defaultContext: NSManagedObjectContext
    
    static var sharedInstance: SBCoreDataManager {
        guard let instance = _instance else {
            fatalError("Call initStack")
        }
        return instance
    }
    
    static func initStack(name: String) {
        if _instance != nil {
            fatalError("Core Data stack already exists")
        }
        _instance = SBCoreDataManager(name: name)
    }
    
    fileprivate init(name: String) {
        modelName = name
        
        var modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")
        if (modelURL == nil) {
            modelURL = Bundle.main.url(forResource: modelName, withExtension: "mom")
        }
        guard let url = modelURL else {
            fatalError("Unable to Find Data Model")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Unable to Load Data Model")
        }
        managedObjectModel = model
        
        let storeName = "\(modelName).sqlite"
        // для использования одним инстансом
        let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        // для использования группой
        //        guard let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.ru.sbsoft.habar") else {
        //            fatalError("Unavable group container")
        //        }
        let storeURL = path.appendingPathComponent(storeName)
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            #if AUTOMIGRATION
            let sqlOption = ["journal_mode": "WAL"]
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true,
                           NSSQLitePragmasOption: sqlOption] as [String : Any]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            #else
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            #endif
        } catch {
            fatalError("Unable to Add Persistent Store")
        }
        
        // инициализация стека контекста
        rootContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        rootContext.persistentStoreCoordinator = persistentStoreCoordinator;
        defaultContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        rootContext.perform {
            self.addObtainPermanentIDsBeforeSaving(context: self.rootContext)
            self.rootContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
        
        defaultContext.parent = rootContext
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rootContextDidSave(notification:)),
                                               name: Notification.Name.NSManagedObjectContextDidSave,
                                               object: rootContext)
        
        
    }
    
    func performSync(_ block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        if Thread.isMainThread {
            block(defaultContext)
        } else {
            let readContext = createChildContext()
            readContext.performAndWait {
                block(readContext)
            }
        }
    }
    
    func performAsync(_ block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        let readContext = createChildContext()
        readContext.perform {
            block(readContext)
        }
    }
    
    func performSyncAndSave(_ block: @escaping (_ context: NSManagedObjectContext) -> Void) -> (Bool, NSError?) {
        var didSave = false
        var nsError: NSError? = nil
        let writeContext = createChildContext()
        writeContext.performAndWait {
            block(writeContext)
            didSave = writeContext .hasChanges
            if didSave {
                do {
                    try writeContext.save()
                    self.rootContext.performAndWait {
                        if self.rootContext.hasChanges {
                            do {
                                try self.rootContext.save()
                            } catch {
                                didSave = false
                                nsError = error as NSError
                            }
                        }
                    }
                } catch {
                    didSave = false
                    nsError = error as NSError
                }
            }
        }
        return (didSave, nsError)
    }
    
    func performAsyncAndSave(_ block: @escaping (_ context: NSManagedObjectContext) -> Void, onComplite: ((_ didSave: Bool, _ error: NSError?) -> Void)? ) {
        let writeContext = createChildContext()
        writeContext.perform {
            block(writeContext)
            if writeContext.hasChanges {
                do {
                    try writeContext.save()
                    self.rootContext.perform {
                        if self.rootContext.hasChanges {
                            do {
                                try self.rootContext.save()
                                if let complite = onComplite {
                                    complite(true, nil)
                                }
                            } catch {
                                let nserror = error as NSError
                                if let complite = onComplite {
                                    complite(false, nserror)
                                }
                            }
                        }
                    }
                } catch {
                    let nserror = error as NSError
                    if let complite = onComplite {
                        complite(false, nserror)
                    }
                }
            } else {
                if let complite = onComplite {
                    complite(false, nil)
                }
            }
        }
    }
    
    func mainTemplateContext() -> NSManagedObjectContext {
        /*
         let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
         context.parent = rootContext
         addObtainPermanentIDsBeforeSaving(context: context)
         return context
         */
        return defaultContext;
    }
    
    func saveMainTemplateContext() -> (Bool, NSError?) {
        var didSave = defaultContext.hasChanges
        var nsError: NSError? = nil
        if didSave {
            do {
                try defaultContext.save()
                if self.rootContext.hasChanges {
                    do {
                        try self.rootContext.save()
                    } catch {
                        didSave = false
                        nsError = error as NSError
                    }
                }
            } catch {
                didSave = false;
                nsError = error as NSError
            }
        }
        return (didSave, nsError)
    }
    
    func rollbackMainTemplateContext() {
        if defaultContext.hasChanges {
            defaultContext.rollback()
        }
    }
    
    // MARK: Private methods
    
    private func addObtainPermanentIDsBeforeSaving(context: NSManagedObjectContext) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextWillSave(notification:)),
                                               name: Notification.Name.NSManagedObjectContextWillSave,
                                               object: nil)
    }
    
    private func createChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = rootContext
        addObtainPermanentIDsBeforeSaving(context: context)
        return context
    }
    
    // MARK: Notification handler
    
    @objc
    func contextWillSave(notification: Notification) {
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
    func rootContextDidSave(notification: Notification) {
        guard let currentContext = notification.object as? NSManagedObjectContext, currentContext === rootContext else {
            return
        }
        
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                self.rootContextDidSave(notification: notification)
            }
            return
        }
        if let dict = notification.userInfo as NSDictionary?, let objects = dict.object(forKey: NSUpdatedObjectsKey) as? [NSManagedObject] {
            for object in objects {
                defaultContext.object(with: object.objectID).willAccessValue(forKey: nil)
            }
        }
        defaultContext.mergeChanges(fromContextDidSave: notification)
    }
    
}
