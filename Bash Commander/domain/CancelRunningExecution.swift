//
//  CancelRunningExecution.swift
//  Bash Commander
//
//  Created by Martin Förster on 28.01.21.
//

import Foundation
import Swift_IoC_Container

protocol CancelRunningExecution {
    func invoke()
}

class CancelRunningExecutionImpl : CancelRunningExecution {
    
    private let bashRepository: BashRepository
    
    init(bashRepository: BashRepository = IoC.shared.resolveOrNil()!) {
        self.bashRepository = bashRepository
    }
    
    func invoke() {
        bashRepository.cancelRunningExecution()
    }
    
    
}
