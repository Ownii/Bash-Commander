//
//  NotifySuccess.swift
//  Bash Commander
//
//  Created by Martin Förster on 19.01.21.
//

import Foundation
import Swift_IoC_Container

protocol NotifySuccess {
    func invoke(command: Command)
}

class NotifySuccessImpl : NotifySuccess {
    
    private let notificationRepository: NotificationRepository
    
    init(
        notificationRepository: NotificationRepository = IoC.shared.resolveOrNil()!
    ) {
        self.notificationRepository = notificationRepository
    }
    
    func invoke(command: Command) {
        notificationRepository.show(title: command.name!, subtitle: "Erfolgreich ausführt", action: "Ausgabe anzeigen")
    }
    
    
}
