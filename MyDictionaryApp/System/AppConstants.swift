//
//  AppConstants.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

struct AppConstants {
    
    static let appColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    static let lightColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    // Имя хранилища CoreData
    static let nameStorage = "MyDictionaryApp"
    // Время задержки сообщения на экране Тренировка
    static let timeShowMessage = 2.0
    // Текст, если нет ассоциации
    static let havntAssociate = "Нет подсказки"
    // Количество очков за угаданное слово
    static let countPoints = 10
    // Минимальное количество символов ответа
    static let minCountAnswer = 5
    
}
