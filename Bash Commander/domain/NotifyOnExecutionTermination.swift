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
    
    private let getCurrentExecution: GetCurrentExecution
    private let notificationRepository: NotificationRepository
    
    init(getCurrentExecution: GetCurrentExecution = IoC.shared.resolveOrNil()!,
         notificationRepository: NotificationRepository = IoC.shared.resolveOrNil()!) {
        self.getCurrentExecution = getCurrentExecution
        self.notificationRepository = notificationRepository
    }
    
    func invoke() -> Observable<Never> {
        return getCurrentExecution.invoke()
            .flatMap { execution -> Observable<String> in
                return execution.do(onError: { _ in
                    self.notificationRepository.show(title: "Failed", subtitle: "Blubb", action: "Ausgabe")
                },
                onCompleted: {
                    self.notificationRepository.show(title: "Succeeded", subtitle: "Blubb", action: "Ausgabe")
                })
            }.ignoreElements()
    }
    
    
}
