//
//  GetExecutionState.swift
//  Bash Commander
//
//  Created by Martin Förster on 28.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

enum ExecutionState {
    case SUCCEEDED
    case FAILED
    case RUNNING
}

protocol GetExecutionState {
    func invoke() -> Observable<ExecutionState>
}

class GetExecutionStateImpl : GetExecutionState {
    
    private let getCurrentExecution: GetCurrentExecution
    
    init(getCurrentExecution: GetCurrentExecution = IoC.shared.resolveOrNil()!) {
        self.getCurrentExecution = getCurrentExecution
    }
    
    func invoke() -> Observable<ExecutionState> {
        return Observable.just(ExecutionState.FAILED)
//        return getCurrentExecution.invoke()
//            .flatMap { execution -> Observable<ExecutionState> in
//                execution.concat()
//            }
    }
    
    
}
