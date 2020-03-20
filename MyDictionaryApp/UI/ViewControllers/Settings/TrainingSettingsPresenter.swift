//
//  TrainingSettingsPresenter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

protocol TrainingSettingsPresenter {
    
    func loadSettings()
    
    func setLanguage(_ language: LanguageEnum)
    
    func setPeriod(_ period: PeriodEnum)
    
}

protocol TrainingSettingsView: BaseViewProtocol {

    func showLanguage(_ language: LanguageEnum)
    
    func showPeriod(_ period: PeriodEnum)

}

class TrainingSettingsPresenterImp: NSObject, TrainingSettingsPresenter {
    
    private weak var view: TrainingSettingsView!
    
    private var router: TrainingSettingsRouter
    
    private var language: LanguageEnum!
    private var period: PeriodEnum!
    
    init(view: TrainingSettingsView, router: TrainingSettingsRouter) {
        self.view = view
        self.router = router
    }
    
    func loadSettings() {
        self.language = UserDefaultManager.shared.language
        self.period = UserDefaultManager.shared.period
        
        view.showLanguage(self.language)
        view.showPeriod(self.period)
    }
    
    func setLanguage(_ language: LanguageEnum) {
        if self.language == language {return}
        self.language = language
        UserDefaultManager.shared.language = language
        view.showLanguage(language)
    }
    
    func setPeriod(_ period: PeriodEnum) {
        if self.period == period {return}
        self.period = period
        UserDefaultManager.shared.period = period
        view.showPeriod(period)
    }
    
}
