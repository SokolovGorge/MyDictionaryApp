//
//  DicrtionaryCellView.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 16.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation

protocol DictionaryCellView {
    
    func displayWord(word: String)
    
    func displayTranslate(translate: String)
    
    func displayArchive(archive: Bool)
    
}
