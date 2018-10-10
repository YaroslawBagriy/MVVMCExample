//
//  ViewController.swift
//  MVVMCExample
//
//  Created by Yaroslaw Bagriy on 10/6/18.
//  Copyright © 2018 Yaroslaw Bagriy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: RepositoryViewModelType
    
    init(viewModel: RepositoryViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //searchbar observable
    var searchBarText: Observable<String> {
        return searchBar
            .rx
            .text
            .map { $0! }
            .filter { $0.count > 0 }
            .throttle(1, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Private
extension MainViewController {
    
    fileprivate func setup() {
        
        tableView.register(UINib(nibName: String(describing: Repository.self), bundle: nil), forCellReuseIdentifier: String(describing: Repository.self))
        
        viewModel
            .fetchRepositories(for: searchBarText) //view model method to fetch the repositories that returns a Driver
            .map { result -> [Repository] in //Map the response and handle an error if exists
                switch result {
                case .success(let repositories):
                    return repositories
                case .failure(let error):
                    print(error.localizedDescription)
                    return []
                }
            }
            //bind the response to the table view using a drive method
            .drive(tableView.rx.items(cellIdentifier: String(describing: Repository.self), cellType: Repository.self)) { row, repository, cell in
                cell.titleLabel.text = repository.name
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx
            .modelSelected(Repository.self)
            .bind(to: viewModel.repositorySubject)
            .disposed(by: disposeBag)
    
    }
}

