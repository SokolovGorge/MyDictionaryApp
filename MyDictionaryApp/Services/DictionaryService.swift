//
//  DictionaryService.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData

protocol DictionaryService {
    
    func getAllNativeWords() -> [NativeWordEntity]
    
    func getNativeWords(startWith beginLetters: String) -> [NativeWordEntity]
    
    func getNativeWords(from date: Date?) -> [NativeWordEntity]
    
    func isExistsWord(_ word: String, id: NSManagedObjectID?) -> Bool
    
}
