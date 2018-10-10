//
//  RepositoryViewModelType.swift
//  MVVMCExample
//
//  Created by Yaroslaw Bagriy on 10/9/18.
//  Copyright © 2018 Yaroslaw Bagriy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire

//this protocol represents a repository view model then anyone can implement this and perform the fetch.
//Make our view model Transitionable
protocol RepositoryViewModelType: Transitionable  {

    var repositorySubject: PublishSubject<Repository> { get }

    func fetchRepositories(for observableText: Observable<String>) -> Driver<Result<[Repository]>>

}

class RepositoryViewModel : RepositoryViewModelType {
    
    fileprivate let disposeBag = DisposeBag()
    var repositorySubject = PublishSubject<Repository>()//add repositorySubject to recive the repositories selected
    weak var navigationCoordinator: CoordinatorType? //add navigationCoordinator property this is a protocol and weak to avoid retain cycles.
    
    init() {
        //subscribe to repositories change
        repositorySubject
            .asObservable()
            .subscribe({ [unowned self] in
                self.navigationCoordinator?.performTransition(transition: .showRepository($0)) //perform the transition
            })
            .addDisposableTo(disposeBag)
    }
    
    func fetchRepositories(for observableText: Observable<String>) -> Driver<Result<[Repository]>> {
        return RepositoryNetworking
            .fetchRepositories(for: observableText)
    }
}
