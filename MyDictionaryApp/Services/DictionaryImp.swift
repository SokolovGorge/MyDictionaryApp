//
//  DictionaryImp.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData

class DictionaryImp: DictionaryService {
    
    func getAllNativeWords() -> [NativeWordEntity] {
        var result: [NativeWordEntity]!
        SBCoreDataManager.sharedInstance.performSync { (context) in
            let request = NSFetchRequest<NativeWordEntity>(entityName: NativeWordEntity.className())
            let sort = NSSortDescriptor(keyPath: \NativeWordEntity.word, ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 50
            request.relationshipKeyPathsForPrefetching = ["translates"]
            do {
                result = try context.fetch(request)
            } catch {
                fatalError("getAllNativeWords error: \(error)")
            }
        }
        return result
    }
    
    func getNativeWords(startWith beginLetters: String) -> [NativeWordEntity] {
        var result: [NativeWordEntity]!
        SBCoreDataManager.sharedInstance.performSync { (context) in
            let request = NSFetchRequest<NativeWordEntity>(entityName: NativeWordEntity.className())
            let sort = NSSortDescriptor(keyPath: \NativeWordEntity.word, ascending: true)
            request.sortDescriptors = [sort]
            request.predicate = NSPredicate(format: "word BEGINSWITH %@", beginLetters)
            request.fetchBatchSize = 50
            request.relationshipKeyPathsForPrefetching = ["translates"]
            do {
                result = try context.fetch(request)
            } catch {
                fatalError("getNativeWords error: \(error)")
            }
        }
        return result
    }
    
    func getNativeWords(from date: Date?) -> [NativeWordEntity] {
        var result: [NativeWordEntity]!
        SBCoreDataManager.sharedInstance.performSync { (context) in
            let request = NSFetchRequest<NativeWordEntity>(entityName: NativeWordEntity.className())
            if let date = date {
                request.predicate = NSPredicate(format: "datecreate > %@ AND archive == %@", date as NSDate, NSNumber(value: false))
            } else {
                request.predicate = NSPredicate(format: "archive == %@", NSNumber(value: false))
            }
            request.relationshipKeyPathsForPrefetching = ["translates"]
            do {
                result = try context.fetch(request)
            } catch {
                fatalError("getNativeWords(from date) error: \(error)")
            }
        }
        return result
    }
    
    
}
