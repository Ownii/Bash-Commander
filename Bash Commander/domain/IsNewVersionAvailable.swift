//
//  IsNewVersionAvailable.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

protocol IsNewVersionAvailable {
    func invoke() -> Observable<Bool>
}

class IsNewVersionAvailableImpl : IsNewVersionAvailable {
    
    private let getNewestRelease: GetNewestRelease
    private let appConfig: AppConfig
    
    init(
        getNewestRelease: GetNewestRelease = IoC.shared.resolveOrNil()!,
        appConfig: AppConfig = IoC.shared.resolveOrNil()!
    ) {
        self.getNewestRelease = getNewestRelease
        self.appConfig = appConfig
    }
    
    func invoke() -> Observable<Bool> {
        return Observable<Int>.timer(.seconds(0), period: .seconds(60*3), scheduler: MainScheduler.instance)
        .flatMap { _ in
            self.getNewestRelease.invoke(useAlreadyLoaded: false)
        }.map { release in
            release.tag_name > self.appConfig.version
        }
    }
}
