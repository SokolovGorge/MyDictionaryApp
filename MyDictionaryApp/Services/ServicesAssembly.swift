//
//  ServiceAssembly.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation

protocol ServicesAssembly {
    
    var dictionaryService: DictionaryService {get}
    
}

extension ServicesAssembly {
    
    var dictionaryService: DictionaryService {
        get {
            return ServicesMap.getDictionaryService()
        }
    }
}
