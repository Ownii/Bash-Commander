//
//  GetCurrentExecution.swift
//  Bash Commander
//
//  Created by Martin Förster on 28.01.21.
//

import Foundation
import Swift_IoC_Container
import RxSwift

protocol GetCurrentExecution {
    func invoke() -> Observable<Observable<String>>
}

class GetCurrentExecutionImpl : GetCurrentExecution {
    
    private let bashRepository: BashRepository
    
    init(bashRepository: BashRepository = IoC.shared.resolveOrNil()!) {
        self.bashRepository = bashRepository
    }
    
    func invoke() -> Observable<Observable<String>> {
        bashRepository.executions
    }
    
    
}
