//
//  TrainingPresenter.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 17.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

enum TrainingState {
    case ready
    case active
}

protocol TrainingPresenter {
    
    var state: TrainingState {get}
    
    func initState()
    func changeState()
    func getCurrentHint() -> String
    func checkAnswer(_ answer: String?, in background: Bool)
}

protocol TrainingView: BaseViewProtocol {
    
    func showState(_ state: TrainingState)
    func showScore(_ score: Int, of total: Int)
    func showWord(_ word: String)
    func showMessage(_ message: String)
    func clearData()
}

class TrainingPresenterImp: NSObject, TrainingPresenter, ServicesAssembly {
    
    private weak var view: TrainingView!
    private var curIndex = 0
    private var curWord = ""
    private var curAnswers = [String]()
    private var flagHint = false;
    private var words = [NativeWordEntity]()
    private var score = 0
    private var total = 0
    
    var state: TrainingState
    
    init(view: TrainingView) {
        self.state = .ready
        self.view = view
        super.init()
    }
    
    func initState() {
        view.showState(state)
    }
    
    func changeState() {
        switch state {
        case .ready:
            startTraining()
        case .active:
            stopTraining()
        }
    }
    
    func getCurrentHint() -> String {
        switch state {
        case .ready:
            return ""
        case .active:
            if let associate = words[curIndex].associate, associate != "" {
                flagHint = true
                return associate
            }
            return AppConstants.havntAssociate
        }
    }
    
    func checkAnswer(_ answer: String?, in background: Bool) {
        if isCorrect(answer: answer) {
            showResultsAndNext(isOk: true)
        } else if !background {
            showResultsAndNext(isOk: false)
        }
    }
        
    //MARK: - Private Methods
    
    
    func startTraining() {
        words = getWords()
        if words.isEmpty {
            view.showMessage("НЕТ СЛОВ!")
            return
        }
        state = .active
        score = 0
        total = 0
        view.showState(state)
        view.showMessage("НАЧАЛИ")
        curIndex = -1
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.timeShowMessage) {[unowned self] () in
            self.nextWord()
        }
    }
    
    func stopTraining() {
        finishTraining(stopMessage: nil)
    }
    
    func nextWord() {
        curIndex += 1
        if curIndex >= words.count {
            finishTraining(stopMessage: "КОНЕЦ")
            return
        }
        curWord = getAskWord(from: words[curIndex])
        curAnswers = getAnswerWords(from: words[curIndex])
        flagHint = false
        view.clearData()
        view.showWord(curWord)
    }

    func getAskWord(from word: NativeWordEntity) -> String {
        switch UserDefaultManager.shared.language {
        case .eng:
            return word.word!
        case .rus:
            for translate in word.translates!.allObjects as! [TranslateWordEntity] {
                if translate.index == 1 {
                    return translate.translate!
                }
            }
            fatalError("Translate error in word \(word.word!)")
        }
    }
    
    func getAnswerWords(from word: NativeWordEntity) -> [String] {
        switch  UserDefaultManager.shared.language {
        case .eng:
            var result = [String]()
            var transArray = word.translates!.allObjects as! [TranslateWordEntity]
            transArray.sort { (entity1, entity2) -> Bool in
                return entity1.index > entity2.index
            }
            for transate in transArray {
                result.append(transate.translate!)
            }
            return result
        case .rus:
            return [word.word!]
        }
    }
    
    func isCorrect(answer: String?) -> Bool {
        guard let answer = answer else {return false}
        for st in curAnswers {
            if answer == st || (answer.count >= AppConstants.minCountAnswer && st.hasPrefix(answer)) {
                return true
            }
        }
        return false
    }
    
    func showResultsAndNext(isOk: Bool) {
        var message: String
        total += AppConstants.countPoints
        if isOk {
            message = "ПРАВИЛЬНО!"
            score += flagHint ? AppConstants.countPoints / 2 : AppConstants.countPoints
        } else {
            message = "НЕ ПРАВИЛЬНО!"
        }
        view.showScore(score, of: total)
        view.showMessage(message)
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.timeShowMessage) {[unowned self] () in
            self.nextWord()
        }
    }

    func finishTraining(stopMessage: String?) {
        if let message = stopMessage {
            view.showMessage(message)
        }
        state = .ready
        view.showState(state)
    }
    
    func getStaringDate() -> Date? {
        var dayComponent = DateComponents()
        let calendar = Calendar.current
        switch UserDefaultManager.shared.period {
        case .weak:
            dayComponent.day = -7
        case .month:
            dayComponent.month = -1
        case .halfYear:
            dayComponent.month = -6
        case .year:
            dayComponent.year = -1
        case .all:
            return nil
        }
        return calendar.date(byAdding: dayComponent, to: Date())
    }
    
    func getWords() -> [NativeWordEntity] {
        var words = dictionaryService.getNativeWords(from: getStaringDate())
        if words.isEmpty {
            return words
        }
        // сортировка
        var result = [NativeWordEntity]()
        while !words.isEmpty {
            result.append(words.remove(at: Int.random(in: 0..<words.count)))
        }
        return result
    }

}
