//
//  MainCoordinator.swift
//  MVVMCExample
//
//  Created by Yaroslaw Bagriy on 10/9/18.
//  Copyright © 2018 Yaroslaw Bagriy. All rights reserved.
//

import UIKit

protocol Transitionable: class {
    weak var navigationCoordinator: CoordinatorType? { get }
}

protocol CoordinatorType: class {
    
    var baseController: UIViewController { get }
    
    func performTransition(transition: Transition)
}

enum Transition {
    
    case showRepository(Repository)
}

class MainCoordinator: CoordinatorType {
    var baseController: UIViewController
    
    init() {
        let viewModel = RepositoryViewModel()
        self.baseController = UINavigationController(rootViewController: MainViewController(viewModel: viewModel))
        viewModel.navigationCoordinator = self
    }
    
    func performTransition(transition: Transition) {
        switch transition {
        case .showRepository(let repository):
            UIApplication.shared.open(URL(string: repository.url)!, options: [:], completionHandler: nil)
        }
    }
}
