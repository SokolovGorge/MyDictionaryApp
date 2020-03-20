//
//  SBCoreDataService.swift
//  SBSampleApp
//
//  Created by Соколов Георгий on 14/01/2019.
//  Copyright © 2019 Соколов Георгий. All rights reserved.
//

import Foundation
import CoreData

protocol SBCoreDataService {
    
    /// Синхронно выполняет блок с объектами coredata в потоке контекста.
    /// Если метод выззывается в основном потоке, то блок выполняется в основном потоке.
    /// - Parameter block: блок работы с объектами coredata
    func performSync(_ block: @escaping (_ context: NSManagedObjectContext) -> Void)
    
    /// Асинхронно выполняет блок с объектами coredata в потоке контекста.
    /// Всегда выполняется в отдельном потоке созданного контекста.
    /// - Parameter block: блок работы с объектами coredata
    func performAsync(_ block: @escaping (_ context: NSManagedObjectContext) -> Void)
    
    /// Синхронно выполняет блок с объектами coredata в потоке контекста и сохраняет контекст в БД.
    /// Всегда выполняется в отдельном потоке созданного контекста.
    /// - Parameter block: блок работы с объектами coredata
    /// - Returns: возвращает кортеж (флаг сохранения данных, ошибка)
    func performSyncAndSave(_ block: @escaping (_ context: NSManagedObjectContext) -> Void) -> (Bool, NSError?)
    
    /// Асинхронно выполняет блок с объектами coredata в потоке контекста и сохраняет контекст в БД.
    /// Всегда выполняется в отдельном потоке созданного контекста.
    /// - Parameter block: блок работы с объектами coredata
    /// - Returns: кортеж (флаг сохранения данных, ошибка)
    func performAsyncAndSave(_ block: @escaping (_ context: NSManagedObjectContext) -> Void, onComplite: ((_ didSave: Bool, _ error: NSError?) -> Void)?)
    
    /// Возвращает контекст главного потока.
    /// Применяется для работы с визуальными компонентами только в главном потоке.
    /// - Returns: контекст главного потока
    func mainTemplateContext() -> NSManagedObjectContext
    
    /// Сохраняет контекст главного потока.
    /// Используется в связке с mainTemplateContext()
    /// - Returns: кортеж (флаг сохранения данных, ошибка)
    func saveMainTemplateContext() -> (Bool, NSError?)
    
    //Отменяет изменения контекста главного потока, если они были.
    func rollbackMainTemplateContext()
    
}

