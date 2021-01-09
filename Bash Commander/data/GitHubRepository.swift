//
//  GitHubRepository.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

enum DataError : Error {
    case cantParseJSON
}

protocol GitHubRepository {
    func getReleases(useAlreadyLoaded: Bool) -> Single<[GitHubRelease]>
}

class GitHubRepositoryImpl : GitHubRepository {
    
    private let appConfig: AppConfig
    
    private let fetchedReleases: [GitHubRelease]? = nil
    
    init(appConfig: AppConfig = IoC.shared.resolveOrNil()!) {
        self.appConfig = appConfig
    }
    
    
    func getReleases(useAlreadyLoaded: Bool) -> Single<[GitHubRelease]> {
        if useAlreadyLoaded, let releases = fetchedReleases {
            return Single.just(releases)
        }
        else {
            return fetchReleases()
        }
    }
    
    private func fetchReleases() -> Single<[GitHubRelease]> {
        let url = URL(string: "https://api.github.com/repos/\(appConfig.gitHubRepo)/releases")!
        return Single.create { single in
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let data = data, let releases = try? JSONDecoder().decode([GitHubRelease].self, from: data) else {
                    single(.failure(DataError.cantParseJSON))
                    return
                }
                
                single(.success(releases))
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
            
        }
    }
}
