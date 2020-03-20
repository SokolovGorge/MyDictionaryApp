//
//  DicrtionaryCell.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 15.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class DictionaryCell: UITableViewCell, DictionaryCellView {

    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var translateLabel: UILabel!
    @IBOutlet var archiveLabel: UILabel!
    
    static let identifier = "dictionaryCell"
    
    //MARK: DicrtionaryCellView
    
    func displayWord(word: String) {
        wordLabel.text = word
    }
    
    func displayTranslate(translate: String) {
        translateLabel.text = translate
    }

    func displayArchive(archive: Bool) {
        archiveLabel.isHidden = !archive
    }

}
