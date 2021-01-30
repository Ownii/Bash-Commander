//
//  NotifyOnExecutionTermination.swift
//  Bash Commander
//
//  Created by Martin Förster on 28.01.21.
//

import Foundation
import RxSwift
import Swift_IoC_Container

protocol NotifyOnExecutionTermination {
    func invoke() -> Observable<Never>
}

class NotifyOnExecutionTerminationImpl : NotifyOnExecutionTermination {
    
    private let getExecutionState: GetExecutionState
    private let notificationRepository: NotificationRepository
    
    init(getExecutionState: GetExecutionState = IoC.shared.resolveOrNil()!,
         notificationRepository: NotificationRepository = IoC.shared.resolveOrNil()!) {
        self.getExecutionState = getExecutionState
        self.notificationRepository = notificationRepository
    }
    
    func invoke() -> Observable<Never> {
        return getExecutionState.invoke()
            .map { state -> String in
                if( state == ExecutionState.SUCCEEDED ) {
                    self.notificationRepository.show(title: NSLocalizedString("success", comment: ""), subtitle: NSLocalizedString("success_subtitle", comment: ""), action: NSLocalizedString("output", comment: ""))
                }
                if( state == ExecutionState.FAILED ) {
                    self.notificationRepository.show(title: NSLocalizedString("fail", comment: ""), subtitle: NSLocalizedString("fail_subtitle", comment: ""), action: NSLocalizedString("output", comment: ""))
                }
                return ""
            }.ignoreElements()
    }
    
    
}
