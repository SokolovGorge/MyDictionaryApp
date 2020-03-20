//
//  TrainingController.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 16.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class TrainingController: UIViewController {
    
    @IBOutlet weak var wordLabel: LTMorphingLabel!
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var messageLabel: LTMorphingLabel!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var execButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var messageTimer: Timer?
    private let buttonHieght: CGFloat = 20.0
    
    var presenter: TrainingPresenter!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hintTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.hintTextView.layer.borderWidth = 1.0
        self.messageLabel.morphingEffect = .anvil
        self.messageLabel.isHidden = true
        self.messageLabel.text = ""
        
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillShowNotification),
                             name: UIWindow.keyboardWillShowNotification,
                             object: nil)
        NotificationCenter.default.addObserver(self,
                             selector: #selector(keyboardWillHideNotification),
                             name: UIWindow.keyboardWillHideNotification,
                             object: nil)

        presenter.initState()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - Notifications
    
    @objc
    func keyboardWillShowNotification(_ notification: NSNotification) {
        if let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
            let animationCurve = UIView.AnimationCurve(rawValue: curveValue.intValue),
            let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let tabBarController = self.tabBarController
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let height = tabBarController.tabBar.frame.height
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationCurve(animationCurve)
            UIView.setAnimationDuration(animationDuration)
            
            self.bottomConstraint.constant = buttonHieght + keyboardHeight - height
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
            
            self.bottomConstraint.constant = buttonHieght
            self.view.layoutIfNeeded()
            
            UIView.commitAnimations()
        }
    }

    
    // MARK: - Actions

    @IBAction func execAction(_ sender: UIButton) {
        presenter.changeState()
    }
    
    @IBAction func hintAction(_ sender: UIButton) {
        hintTextView.text = presenter.getCurrentHint()
    }
    
    @IBAction func answerAction(_ sender: UIButton) {
        presenter.checkAnswer(answerField.text, in: false)
    }
}

//MARK: - TrainingView

extension TrainingController: TrainingView {
    
    func showState(_ state: TrainingState) {
        switch state {
        case .active:
            showScore(0, of: 0)
            execButton.setTitle("СТОП", for: .normal)
            answerField.becomeFirstResponder()
        case .ready:
            answerField.text = ""
            answerField.resignFirstResponder()
            answerButton.isEnabled = false
            execButton.setTitle("СТАРТ", for: .normal)
        }
        showWord("")
        hintTextView.text = ""
    }
    
    func showScore(_ score: Int, of total: Int) {
        navigationItem.title =  "Счет: \(score) из \(total)"
    }
    
    func showWord(_ word: String) {
        hintTextView.text = ""
        
        let effect = LTMorphingEffect(rawValue: Int.random(in: 0..<6))!
        self.wordLabel.morphingEffect = effect
        self.wordLabel.text = word
    }
    
    func showMessage(_ message: String) {
        if let timer = messageTimer {
            timer.invalidate()
            messageTimer = nil
        }
        self.messageLabel.text = message
        self.messageLabel.isHidden = false
        messageTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.timeShowMessage, repeats: false, block: {[unowned self] (_) in
            self.messageLabel.isHidden = true
            self.messageLabel.text = ""
        })
    }
    
    func clearData() {
        answerField.text = ""
        hintTextView.text = ""
        answerButton.isEnabled = false
    }

}

//MARK: - UITextFieldDelegate

extension TrainingController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch presenter.state {
        case .active:
            var newString: String? = nil
            if let text = textField.text, let textRange = Range(range, in: text) {
                newString = text.replacingCharacters(in: textRange, with: string)
            }
            answerButton.isEnabled = newString != nil && newString! != ""
            if newString != nil && newString!.count >= AppConstants.minCountAnswer {
                presenter.checkAnswer(newString, in: true)
            }
            return true
        case .ready:
            answerButton.isEnabled = false
            return false
            //textField.text = ""
        }
    }
    
    
}
