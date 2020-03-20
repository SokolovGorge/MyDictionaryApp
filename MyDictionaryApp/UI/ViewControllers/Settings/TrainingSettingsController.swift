//
//  TrainingSettingsController.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 09.03.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit

class TrainingSettingsController: UITableViewController {
    
    @IBOutlet weak var englishCheckImage: UIImageView!
    @IBOutlet weak var russianCheckImage: UIImageView!
    
    @IBOutlet weak var weekCheckImage: UIImageView!
    @IBOutlet weak var monthCheckImage: UIImageView!
    @IBOutlet weak var halfCheckImage: UIImageView!
    @IBOutlet weak var yearCheckImage: UIImageView!
    @IBOutlet weak var allCheckImage: UIImageView!
    
    var presenter: TrainingSettingsPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadSettings()
    }

    // MARK: - UITableviewDelegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                presenter.setLanguage(.eng)
            case 1:
                presenter.setLanguage(.rus)
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0:
                presenter.setPeriod(.weak)
            case 1:
                presenter.setPeriod(.month)
            case 2:
                presenter.setPeriod(.halfYear)
            case 3:
                presenter.setPeriod(.year)
            case 4:
                presenter.setPeriod(.all)
            default: break
            }
        default: break
        }
    }
    
}

//MARK: - TrainingSettingsController

extension TrainingSettingsController: TrainingSettingsView {
    
    func showLanguage(_ language: LanguageEnum) {
        englishCheckImage.isHidden = language != .eng
        russianCheckImage.isHidden = language != .rus
    }
    
    func showPeriod(_ period: PeriodEnum) {
        weekCheckImage.isHidden = period != .weak
        monthCheckImage.isHidden = period != .month
        halfCheckImage.isHidden = period != .halfYear
        yearCheckImage.isHidden = period != .year
        allCheckImage.isHidden = period != .all
    }

}
