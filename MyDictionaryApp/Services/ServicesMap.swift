//
//  ServicesMap.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation

class ServicesMap {
    
    private static var dictionaryService: DictionaryService?
    
    static func getDictionaryService() -> DictionaryService {
        guard let service = dictionaryService else {
            dictionaryService = DictionaryImp()
            return dictionaryService!
        }
        return service
    }
    
    static func setDictionaryService(service: DictionaryService) {
        dictionaryService = service
    }
    
}
