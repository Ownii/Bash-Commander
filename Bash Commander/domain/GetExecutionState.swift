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
        return Observable.create { observer in
            return self.getCurrentExecution.invoke().flatMap { execution -> Observable<String> in
                observer.onNext(.RUNNING)
                return execution.do(onError: { _ in
                    observer.onNext(.FAILED)
                }, onCompleted: {
                    observer.onNext(.SUCCEEDED)
                }).catchAndReturn("")
                
            }.subscribe()
        }.distinctUntilChanged()
    }
}
