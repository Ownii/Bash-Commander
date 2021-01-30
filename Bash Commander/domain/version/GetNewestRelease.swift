//
//  GetNewestRelease.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

protocol GetNewestRelease {
    func invoke(useAlreadyLoaded: Bool) -> Single<GitHubRelease>
}

class GetNewestReleaseImpl : GetNewestRelease {
    
    private let gitHubRepository: GitHubRepository
    
    init(gitHubRepository: GitHubRepository = IoC.shared.resolveOrNil()! ) {
        self.gitHubRepository = gitHubRepository
    }
    
    func invoke(useAlreadyLoaded: Bool) -> Single<GitHubRelease> {
        gitHubRepository.getReleases(useAlreadyLoaded: useAlreadyLoaded).map { releases in
            releases.filter { release in
                !release.draft && release.target_commitish == "master"
            }.sorted { $0.tag_name > $1.tag_name }
            .first!
        }
    }
    
    
}
