//
//  EditWordController.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 16.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class EditWordController: UIViewController {
    
    @IBOutlet weak var wordEdit: UITextField!
    @IBOutlet weak var transcriptEdit: UITextField!
    
    @IBOutlet weak var translateEdit1: UITextField!
    @IBOutlet weak var translateEdit2: UITextField!
    @IBOutlet weak var translateEdit3: UITextField!
    @IBOutlet weak var translateEdit4: UITextField!
    @IBOutlet weak var translateEdit5: UITextField!
    @IBOutlet weak var translateEdit6: UITextField!
    @IBOutlet weak var translateEdit7: UITextField!
    @IBOutlet weak var translateEdit8: UITextField!
    @IBOutlet weak var translateEdit9: UITextField!
    @IBOutlet weak var translateEdit10: UITextField!
    
    @IBOutlet weak var associationView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var presenter: EditWordPresenter!
    var wordEntity: NativeWordEntity?


    override func viewDidLoad() {
        super.viewDidLoad()

        associationView.layer.borderColor = UIColor.lightGray.cgColor
        associationView.layer.borderWidth = 1
        
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillShowNotification),
                             name: UIWindow.keyboardWillShowNotification,
                             object: nil)
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillHideNotification),
                             name: UIWindow.keyboardWillHideNotification,
                             object: nil)
        
        if let wordEntity = self.wordEntity {
            self.navigationItem.title = "Редактирование"
            presenter.setWordEntity(wordEntity)
        } else {
            self.navigationItem.title = "Новое слово"
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        presenter.checkDataState()
    }
                
    //MARK: - Notifications
    
    @objc
    func keyboardWillShowNotification(_ notification: NSNotification) {
        if let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationCurve = UIView.AnimationCurve(rawValue: curveValue.intValue),
            let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(animationCurve)
            UIView.setAnimationDuration(animationDuration)
            
            self.bottomConstraint.constant = -(keyboardHeight - safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
            
            UIView.commitAnimations()
        }
     }

    @objc
    func keyboardWillHideNotification(_ notification: NSNotification) {
        if let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationCurve = UIView.AnimationCurve(rawValue: curveValue.intValue),
            let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(animationCurve)
            UIView.setAnimationDuration(animationDuration)
            
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            
            UIView.commitAnimations()
        }
    }
    
    //MARK: - Actions
        
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        presenter.saveData()
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension EditWordController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField !== transcriptEdit {
            return
        }
        if textField.text == nil || (textField.text?.first != "[") {
            textField.text = "[" + (textField.text ?? "")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField !== transcriptEdit {
            return
        }
        if let text = textField.text {
            if text == "[" {
                textField.text = ""
            } else if text.first == "[" && text.last != "]" && text.count > 2 {
                textField.text = text + "]"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === wordEdit {
            transcriptEdit.becomeFirstResponder()
        } else if textField === transcriptEdit {
            translateEdit1.becomeFirstResponder()
        } else if textField === translateEdit1 {
            translateEdit2.becomeFirstResponder()
        } else if textField === translateEdit2 {
            translateEdit3.becomeFirstResponder()
        } else if textField === translateEdit3 {
            translateEdit4.becomeFirstResponder()
        } else if textField === translateEdit4 {
            translateEdit5.becomeFirstResponder()
        } else if textField === translateEdit5 {
            translateEdit6.becomeFirstResponder()
        } else if textField === translateEdit6 {
            translateEdit7.becomeFirstResponder()
        } else if textField === translateEdit7 {
            translateEdit8.becomeFirstResponder()
        } else if textField === translateEdit8 {
            translateEdit9.becomeFirstResponder()
        } else if textField === translateEdit9 {
            translateEdit10.becomeFirstResponder()
        } else if textField === translateEdit10 {
            associationView.becomeFirstResponder()
        }
        return true
    }
}

//MARK: - EditWordView

extension EditWordController: EditWordView {
    
    func wordBecomeResponder() {
        wordEdit.becomeFirstResponder()
    }
    
    func firstTranslateBecomeResponder() {
        translateEdit1.becomeFirstResponder()
    }
        
    func getWordValue() -> String? {
        return self.wordEdit.text
    }
    
    func getTranscriptValue() -> String? {
        return self.transcriptEdit.text
    }
    
    func getAssociationValue() -> String? {
        return self.associationView.text
    }
    
    func getTranslateValue1() -> String? {
        return self.translateEdit1.text
    }
    
    func getTranslateValue2() -> String? {
        return self.translateEdit2.text
    }
    
    func getTranslateValue3() -> String? {
        return self.translateEdit3.text
    }
    
    func getTranslateValue4() -> String? {
        return self.translateEdit4.text
    }
    
    func getTranslateValue5() -> String? {
        return self.translateEdit5.text
    }
    
    func getTranslateValue6() -> String? {
        return self.translateEdit6.text
    }
    
    func getTranslateValue7() -> String? {
        return self.translateEdit7.text
    }
    
    func getTranslateValue8() -> String? {
        return self.translateEdit8.text
    }
    
    func getTranslateValue9() -> String? {
        return self.translateEdit9.text
    }
    
    func getTranslateValue10() -> String? {
        return self.translateEdit10.text
    }
    
    func setWordValue(_ value: String?) {
        wordEdit.text = value
    }
    
    func setTranscriptValue(_ value: String?) {
        transcriptEdit.text = value
    }
    
    func setAssociationValue(_ value: String?) {
        associationView.text = value
    }
    
    func setTranslateValue(_ value: String?, index: Int) {
        switch index {
        case 1:
            translateEdit1.text = value
        case 2:
            translateEdit2.text = value
        case 3:
            translateEdit3.text = value
        case 4:
            translateEdit4.text = value
        case 5:
            translateEdit5.text = value
        case 6:
            translateEdit6.text = value
        case 7:
            translateEdit7.text = value
        case 8:
            translateEdit8.text = value
        case 9:
            translateEdit9.text = value
        case 10:
            translateEdit10.text = value
        default:
            fatalError("Not valid index: \(index)")
        }
    }

}

