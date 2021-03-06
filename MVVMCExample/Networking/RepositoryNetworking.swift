//
//  RepositoryNetworking.swift
//  MVVMCExample
//
//  Created by Yaroslaw Bagriy on 10/9/18.
//  Copyright © 2018 Yaroslaw Bagriy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxAlamofire
import Alamofire
import ObjectMapper

enum CommonError : Error {
    
    case parsingError
    case networkError
}

struct RepositoryNetworking {
    
    static func fetchRepositories(for repositoryName: Observable<String>) -> Driver<Result<[Repository]>> {
        return repositoryName
            .subscribeOn(MainScheduler.instance) // Make sure we are on MainScheduler
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            .flatMapLatest { text in // .Background thread, network request
                return requestJSON(.get, "https://api.github.com/users/\(text)/repos").debug()
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background)) // we don’t really know from the code above that requestJSON will return data on the same thread it started. So we’re gonna make sure it is again on the background thread for mapping.
            .map { (response, json) -> Result<[Repository]> in
                if response.statusCode == 200 {
                    
                    guard let json = json as? [[String : Any]] else { return .failure(CommonError.parsingError) }
                    
                    if let repos = Mapper<Repository>().mapArray(JSONArray: json) {
                        return .success(repos)
                    } else {
                        return .failure(CommonError.parsingError)
                    }
                } else {
                    return .failure(CommonError.networkError)
                }
            }
            .observeOn(MainScheduler.instance) // switch to MainScheduler, UI updates
            .do(onNext: { _ in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
            .asDriver(onErrorJustReturn: .failure(CommonError.parsingError)) // This also makes sure that we are on MainScheduler
    }
}

//Repository Model
class Repository: Mappable {
    
    var identifier: Int!
    var language: String!
    var url: String!
    var name: String!
    
    required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        identifier <- map["id"]
        language <- map["language"]
        url <- map["url"]
        name <- map["name"]
    }
}
