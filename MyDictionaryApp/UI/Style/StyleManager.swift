//
//  StyleManager.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

struct StyleManager {
    
    static func applyStyles() {
        applyNavigationBarStyle()
        applyTabBarStyle()
    }
    
    private static func applyNavigationBarStyle() {
        let navigateionBarAppearance = UINavigationBar.appearance()
        navigateionBarAppearance.barStyle = .black
//        navigateionBarAppearance.isTranslucent = false
        navigateionBarAppearance.barTintColor = AppConstants.appColor
        navigateionBarAppearance.tintColor = AppConstants.lightColor
        navigateionBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppConstants.lightColor]
    }
    
    private static func applyTabBarStyle() {
        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.tintColor = AppConstants.appColor
    }
    
}
