//
//  CommandsRepository.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import Foundation
import Cocoa
import Swift_IoC_Container
import RxSwift

protocol CommandsRepository {
    
    func getCommands() -> Observable<[Command]>
    
    func addCommand(name: String, path: String, command: String, group: String)
    
    func deleteCommand(cmd: Command)
    
    func saveChanges()
    
    
}

class CommandsRepositoryImpl:  CommandsRepository {
    
    private lazy var commandsSubject: BehaviorSubject<[Command]> = { BehaviorSubject<[Command]>(value: loadCommands()) }()
    
    let container : NSPersistentContainer
    
    init(container: NSPersistentContainer = IoC.shared.resolveOrNil()!) {
        self.container = container
    }
        
    func addCommand(name: String, path: String, command: String, group: String) {
        let managedCommand = NSEntityDescription.insertNewObject(forEntityName: "Command", into: container.viewContext) as! Command
        managedCommand.command = command
        managedCommand.name = name
        managedCommand.path = path
        managedCommand.group = group
        try! container.viewContext.save()
        onCommandsChanged()
    }
    
    func getCommands() -> Observable<[Command]> {
        return commandsSubject
        
    }
    
    private func loadCommands() -> [Command] {
        return try! container.viewContext.fetch(Command.fetchRequest())
    }
    
    private func onCommandsChanged() {
        commandsSubject.onNext(loadCommands())
    }
    
    func deleteCommand(cmd: Command) {
        container.viewContext.delete(cmd)
        onCommandsChanged()
    }
    
    func saveChanges() {
        try! container.viewContext.save()
        onCommandsChanged()
    }
    
}
