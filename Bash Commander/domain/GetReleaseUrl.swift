//
//  GetReleaseUrl.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

protocol GetReleaseUrl {
    func invoke() -> Single<URL>
}

class GetReleaseUrlImpl : GetReleaseUrl {
    
    private let getNewestRelease: GetNewestRelease
    
    init(getNewestRelease: GetNewestRelease = IoC.shared.resolveOrNil()!) {
        self.getNewestRelease = getNewestRelease
    }
    
    func invoke() -> Single<URL> {
        getNewestRelease.invoke(useAlreadyLoaded: true).map { release in
            URL(string: release.html_url)!
        }
    }
}
