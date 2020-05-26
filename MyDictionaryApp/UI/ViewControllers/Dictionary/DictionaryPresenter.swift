//
//  DictionaryPresenter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 13.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit
import CoreData

protocol DictionaryPresenter {
    
    func getNumberSections() -> Int
    
    func getCountInSection(_ section: Int) -> Int
    
    func updateData(byFilter filter:String)
    
    func getTitleSection(_ section: Int) -> String?
    
    func configure(cell: DictionaryCellView, for indexPath: IndexPath)
    
    func sectionIndexTitles() -> [String]
    
    func deleteRow(at indexPath: IndexPath)
    
    func newItem()
    
    func editItem(at indexPath: IndexPath)
    
    func getItem(at indexPath: IndexPath) -> NativeWordEntity
    
    func deleteItem(at indexPath: IndexPath)
    
    func setAcrhive(_ archive: Bool, at indexPath: IndexPath)
    
}

protocol DictionaryView: BaseViewProtocol {
    
    func reloadData()
    
    func beginUpdates()
    
    func endUpdates()
    
    func insertSection(at sectionIndex: Int)
    
    func deleteSection(at sectionIndex: Int)
    
    func insertRow(at indexPath: IndexPath)
    
    func deleteRow(at indexPath: IndexPath)
    
    func updateRow(at indexPath: IndexPath)
    
    func cancelSearchController()
    
}

class DictionaryPresenterImp: NSObject, DictionaryPresenter {
    
        
    private weak var view: DictionaryView!
    private var router: DictionaryRouter
    
    private var condition: String = "n/a"
    private var fetchResultController: NSFetchedResultsController<NativeWordEntity>!
    
    init(view: DictionaryView, router: DictionaryRouter) {
        self.view = view
        self.router = router
        
    }
    
    //MARK: DictionaryPresenter
    
    func getNumberSections() -> Int {
        return fetchResultController.sections?.count ?? 0
    }
    
    func getCountInSection(_ section: Int) -> Int{
        guard let sections = fetchResultController.sections else {return 0}
        return sections[section].numberOfObjects
    }
    
    func getTitleSection(_ section: Int) -> String?{
        guard let sections = fetchResultController.sections else {return nil}
        return sections[section].name
    }
    
    func updateData(byFilter filter:String) {
        if filter == condition {
            return
        }
        condition = filter
        let request = NSFetchRequest<NativeWordEntity>(entityName: NativeWordEntity.className())
        let sortDescriptor = NSSortDescriptor(keyPath: \NativeWordEntity.word, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        if filter != "" {
            request.predicate = NSPredicate(format: "word BEGINSWITH %@", filter)
        }
        request.fetchBatchSize = 20
        request.relationshipKeyPathsForPrefetching = ["translates"]
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: SBCoreDataManager.shared.mainTemplateContext(), sectionNameKeyPath: "section", cacheName: nil)
        self.fetchResultController = controller
        controller.delegate = self
        do {
            try self.fetchResultController.performFetch()
            view.reloadData()
        } catch {
            let nserror = error as NSError
            fatalError("Fetch error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func configure(cell: DictionaryCellView, for indexPath: IndexPath) {
        let wordEntity = fetchResultController.object(at: indexPath)
        let sortDescriptor = NSSortDescriptor(keyPath: \TranslateWordEntity.index, ascending: true)
        let translates = wordEntity.translates?.sortedArray(using: [sortDescriptor]) as! [TranslateWordEntity]
        cell.displayWord(word: wordEntity.word!)
        if translates.count > 1 {
            var st = ""
            for translate in translates {
                st += " \(translate.index)) \(translate.translate!)"
            }
            cell.displayTranslate(translate: st)
        } else {
            cell.displayTranslate(translate: translates[0].translate!)
        }
        cell.displayArchive(archive: wordEntity.archive)
    }
    
    func sectionIndexTitles() -> [String] {
        return fetchResultController.sectionIndexTitles
    }
    
    func deleteRow(at indexPath: IndexPath) {
        let context = fetchResultController.managedObjectContext
        context.delete(fetchResultController.object(at: indexPath))
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Delete error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func newItem() {
        router.callEditWordController(with: nil)
    }
    
    func editItem(at indexPath: IndexPath) {
        let wordEntity = fetchResultController.object(at: indexPath)
        view.cancelSearchController()
        router.callEditWordController(with: wordEntity)
    }
    
    func getItem(at indexPath: IndexPath) -> NativeWordEntity {
        return fetchResultController.object(at: indexPath)
    }
    
    func setAcrhive(_ archive: Bool, at indexPath: IndexPath) {
        let entity = getItem(at: indexPath)
        entity.archive = archive
        _ = SBCoreDataManager.shared.saveMainTemplateContext()
    }
    
    func deleteItem(at indexPath: IndexPath) {
        let entity = getItem(at: indexPath)
        SBCoreDataManager.shared.mainTemplateContext().delete(entity)
        _ = SBCoreDataManager.shared.saveMainTemplateContext()
    }

}

//MARK: - NSFetchedResultsControllerDelegate

extension DictionaryPresenterImp: NSFetchedResultsControllerDelegate {
   
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        view.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            view.insertSection(at: sectionIndex)
        case .delete:
            view.deleteSection(at: sectionIndex)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                view.insertRow(at: indexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                view.deleteRow(at: indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                view.updateRow(at: indexPath)
            }
        case .move:
            break
        default:
            break
        }
    }
}

