//
//  DictionaryController.swift
//  MyDictionaryApp
//
//  Created by Соколов Георгий on 11.02.2020.
//  Copyright © 2020 Соколов Георгий. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DictionaryController: UITableViewController, ServicesAssembly {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    
    var presenter: DictionaryPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        let searchField = searchController.searchBar.value(forKeyPath: "searchField") as! UITextField
        searchField.placeholder = "Фильтр"
        searchField.autocapitalizationType = .none
        searchField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let bgView = searchField.subviews.first
        if let view = bgView {
            view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
        }
        
        searchController.searchBar.rx.text
            .debounce(1, scheduler: MainScheduler.instance)
            .filter { $0?.count ?? 0 != 1} // пропускаем только первую букву
            .subscribe(onNext: {[unowned self] (text) in
                if let text = text {
                    self.presenter.updateData(byFilter: text)
                }
            })
            .disposed(by: disposeBag)
        
        presenter.updateData(byFilter: "")
                
    }
        
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return presenter.getCountInSection(section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DictionaryCell.identifier, for: indexPath) as! DictionaryCell
        presenter.configure(cell: cell, for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter.deleteRow(at: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") {[unowned self] (action, indexPath) in
            self.presenter.deleteItem(at: indexPath)
        }
        let wordEntity = presenter.getItem(at: indexPath)
        var otherAction: UITableViewRowAction
        if wordEntity.archive {
            otherAction = UITableViewRowAction(style: .normal, title: "Из архива") {[unowned self] (action, indexPath) in
                self.presenter.setAcrhive(false, at: indexPath)
            }
        } else {
            otherAction = UITableViewRowAction(style: .normal, title: "В архив") {[unowned self] (action, indexPath) in
                self.presenter.setAcrhive(true, at: indexPath)
            }
        }
        return [deleteAction, otherAction]
    }
 
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        presenter.editItem(at: indexPath)
    }

    //MARK: Actions
    
    @IBAction func newItemAction(_ sender: UIBarButtonItem) {
        presenter.newItem()
    }
    
}

extension DictionaryController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            presenter.updateData(byFilter: text)
        }
    }
}

extension DictionaryController: DictionaryView {
    
    func beginUpdates() {
        tableView.beginUpdates()
    }
    
    func endUpdates() {
        tableView.endUpdates()
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func insertRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
     }
    
    func deleteRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func updateRow(at indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DictionaryCell {
            presenter.configure(cell: cell, for: indexPath)
        }
    }
    
    func cancelSearchController() {
        if searchController.isActive {
            searchController.isActive = false
        }
    }

}
