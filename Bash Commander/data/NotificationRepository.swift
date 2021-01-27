//
//  NotificationRepository.swift
//  Bash Commander
//
//  Created by Martin Förster on 19.01.21.
//

import Foundation
import UserNotifications

protocol NotificationRepository {
    
    func show(title: String, subtitle: String, action: String?)
    
}

class NotificationRepositoryImpl : NotificationRepository {
    
    
    private let center = UNUserNotificationCenter.current()
    private var isGranted = false
    
    init(delegate: UNUserNotificationCenterDelegate) {
        center.requestAuthorization(options: []) { granted, error in
            self.isGranted = granted
        }
        let show = UNNotificationAction(identifier: "output", title: "Ausgabe anzeigen", options: .foreground)
        let category = UNNotificationCategory(identifier: "COMMAND_EXECUTION", actions: [show], intentIdentifiers: [])

        center.setNotificationCategories([category])
        center.delegate = delegate
    }
    
    func show(title: String, subtitle: String, action: String?) {
        if( isGranted ) {
            let notification = UNMutableNotificationContent()
            notification.title = title
            notification.body = subtitle
            notification.categoryIdentifier = "COMMAND_EXECUTION"

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil)
            center.add(request)
        }
    }
}
