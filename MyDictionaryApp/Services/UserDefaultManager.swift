//
//  UserDefaultManager.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 10.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import Foundation

class UserDefaultManager {
    
    private let kSavedLanguage = "SavedLanguage"
    private let kSavedPeriod = "SavedPeriod"
    
    static let shared = UserDefaultManager()
    
    var language: LanguageEnum {
        get {
            guard let stVal = UserDefaults.standard.value(forKey: kSavedLanguage) as? String else {return .eng}
            return LanguageEnum(rawValue: stVal)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kSavedLanguage)
        }
    }
    
    var period: PeriodEnum {
        get {
            guard let stVal = UserDefaults.standard.value(forKey: kSavedPeriod) as? String else {return .weak}
            return PeriodEnum(rawValue: stVal)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: kSavedPeriod)
        }
    }
    
}

enum LanguageEnum: String {
    case eng
    case rus
}

enum PeriodEnum: String {
    case weak
    case month
    case halfYear
    case year
    case all
}
