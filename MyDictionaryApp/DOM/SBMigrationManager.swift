//
//  SBMigrationManager.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 14.04.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit
import CoreData

@objc protocol SBMigrationManagerDelegate: NSObjectProtocol {
    
@objc optional func migrationManager(_ manager: SBMigrationManager, migrationProgress progress: Float)
    
@objc optional func migrationManager(_ manager: SBMigrationManager, mappingModelsForSourceModel sourceModel: NSManagedObjectModel)
    
}

class SBMigrationManager: NSObject {
    
    public var delegate: SBMigrationManagerDelegate?
    
    private func getModelPaths() -> [String] {
        var modelPaths = [String]()
        let momdArray = Bundle.main.paths(forResourcesOfType: "momd", inDirectory: nil)
        for momdPath in momdArray {
            let resourceSubpath = (momdPath as NSString).lastPathComponent
            let array = Bundle.main.paths(forResourcesOfType: "mom", inDirectory: resourceSubpath)
            modelPaths.append(contentsOf: array)
        }
        let otherModels = Bundle.main.paths(forResourcesOfType: "mom", inDirectory: nil)
        modelPaths.append(contentsOf: otherModels)
        modelPaths.sort { (s1, s2) -> Bool in
            return s1 < s2
        }
        return modelPaths
    }
    
    private func destinationStoreURLWith(sourceStoreURL: NSURL, modelName: String) -> URL {
        let storeExtension = sourceStoreURL.pathExtension!
        let storePath = (sourceStoreURL.path! as NSString).deletingPathExtension
        return NSURL.fileURL(withPath: storePath + "." + modelName + "." + storeExtension)
    }
    
    private func backupSourceStoreAtURL(sourceStoreURL: URL,
                                   movingDestinationStoreAtURL destinationStoreURL: URL) throws {
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let backupPath = NSTemporaryDirectory() + guid
        try FileManager.default.moveItem(atPath: sourceStoreURL.path, toPath: backupPath)
        try FileManager.default.moveItem(atPath: destinationStoreURL.path, toPath: sourceStoreURL.path)
        try FileManager.default.moveItem(atPath: backupPath, toPath: sourceStoreURL.path)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "migrationProgress" {
            if let obj = object as? NSMigrationManager {
                print("progress: \(obj.migrationProgress)")
                if let delg = self.delegate {
                    if delg.responds(to: #selector(SBMigrationManagerDelegate.migrationManager(_:migrationProgress:))) {
                        delg.migrationManager?(self, migrationProgress: obj.migrationProgress)
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
