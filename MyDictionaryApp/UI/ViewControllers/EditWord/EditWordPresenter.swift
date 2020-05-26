//
//  EditWordPresenter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 18.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

protocol EditWordPresenter {
    
    func setWordEntity(_ wordEntity: NativeWordEntity?)
    func saveData() -> Bool
    func checkDataState()
    
}

protocol EditWordView: BaseViewProtocol {
    
    func wordBecomeResponder()
    func firstTranslateBecomeResponder()
    
    func getWordValue() -> String?
    func getTranscriptValue() -> String?
    func getAssociationValue() -> String?
    func getTranslateValue1() -> String?
    func getTranslateValue2() -> String?
    func getTranslateValue3() -> String?
    func getTranslateValue4() -> String?
    func getTranslateValue5() -> String?
    func getTranslateValue6() -> String?
    func getTranslateValue7() -> String?
    func getTranslateValue8() -> String?
    func getTranslateValue9() -> String?
    func getTranslateValue10() -> String?
    
    func setWordValue(_ value: String?)
    func setTranscriptValue(_ value: String?)
    func setAssociationValue(_ value: String?)
    func setTranslateValue(_ value: String?, index: Int)
}

class EditWordPresenterImp: NSObject, EditWordPresenter, ServicesAssembly {
    
    private var flagNeedRolback = true
    private var wordEntity: NativeWordEntity?
    private weak var view: EditWordView!
    
    init(view: EditWordView) {
        self.view = view
    }
    
    func setWordEntity(_ wordEntity: NativeWordEntity?) {
        self.wordEntity = wordEntity
        if let entity = self.wordEntity {
            showData(wordEntity: entity)
        }
    }

    private func isValidValue(_ value: String?) -> Bool {
        return value != nil && value!.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }
    
    func saveData() -> Bool {
        if checkValidData() {
            if dictionaryService.isExistsWord(view.getWordValue()!.lowercased(), id: (wordEntity != nil) ? wordEntity!.objectID : nil) {
                view.showAlertIn(withTitle: "Внимание", message: "Данное слово уже содержится в словаре!", firstButtonTitle: "Ok", otherButtonTitle: nil, tapBlock: nil)
                return false
            }
            writeData()
            return true
        }
        return false
    }
    
    func checkDataState() {
        if flagNeedRolback {
            SBCoreDataManager.shared.rollbackMainTemplateContext()
        }
    }
    
    private func showData(wordEntity: NativeWordEntity) {
        view.setWordValue(wordEntity.word)
        view.setTranscriptValue(wordEntity.transcription)
        view.setAssociationValue(wordEntity.associate)
        if let translates = wordEntity.translates {
            var transArray = translates.allObjects as! [TranslateWordEntity]
            transArray.sort { (entity1, entity2) -> Bool in
                return entity1.index > entity2.index
            }
            for entity in transArray {
                view.setTranslateValue(entity.translate, index: Int(entity.index))
            }
        }
    }

    private func checkValidData() -> Bool {
        if !isValidValue(view.getWordValue()) {
            view.showAlertIn(withTitle: "Внимание",
                        message: "Не заполнено слово!",
                        firstButtonTitle: "Ок",
                        otherButtonTitle: nil) {[unowned self] (actionType) in
                            self.view.wordBecomeResponder()
            }
            return false
        }
        if !isValidValue(view.getTranslateValue1()) &&
            !isValidValue(view.getTranslateValue2()) &&
            !isValidValue(view.getTranslateValue3()) &&
            !isValidValue(view.getTranslateValue4()) &&
            !isValidValue(view.getTranslateValue5()) &&
            !isValidValue(view.getTranslateValue6()) &&
            !isValidValue(view.getTranslateValue7()) &&
            !isValidValue(view.getTranslateValue8()) &&
            !isValidValue(view.getTranslateValue9()) &&
            !isValidValue(view.getTranslateValue10()) {
            view.showAlertIn(withTitle: "Внимание",
                        message: "Не заполнено ни одного перевода!",
                        firstButtonTitle: "Ок",
                        otherButtonTitle: nil) {[unowned self] (actionType) in
                            self.view.firstTranslateBecomeResponder()
            }
            return false
        }
        return true
    }

    private func writeData() {
        if wordEntity == nil {
            wordEntity = NativeWordEntity(context: SBCoreDataManager.shared.mainTemplateContext())
            wordEntity?.datecreate = Date()
        }
        wordEntity?.word = view.getWordValue()?.lowercased()
        wordEntity?.section = String((wordEntity?.word?.prefix(1))!)
        wordEntity?.transcription = view.getTranscriptValue()
        wordEntity?.associate = view.getAssociationValue()
        wordEntity?.translates = nil
        var index: Int16 = 1
        addTranslateValue(view.getTranslateValue1(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue2(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue3(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue4(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue5(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue6(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue7(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue8(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue9(), to: wordEntity!, &index)
        addTranslateValue(view.getTranslateValue10(), to: wordEntity!, &index)
        //
        let (_, error) = SBCoreDataManager.shared.saveMainTemplateContext()
        if let error = error {
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
        flagNeedRolback = false
    }
    
    private func addTranslateValue(_ translateValue: String?, to wordEntity: NativeWordEntity, _ index: inout Int16) {
        if isValidValue(translateValue) {
            let translateEntity1 = TranslateWordEntity(context: SBCoreDataManager.shared.mainTemplateContext())
            translateEntity1.index = index
            translateEntity1.translate = translateValue!.trimmingCharacters(in: .whitespacesAndNewlines)
            translateEntity1.native = wordEntity
            index += 1;
        }
    }
}


