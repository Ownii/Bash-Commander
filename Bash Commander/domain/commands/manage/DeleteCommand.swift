//
//  DeleteCommand.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import Foundation
import Swift_IoC_Container

protocol DeleteCommand {
    func invoke(command: Command)
}

class DeleteCommandImpl : DeleteCommand {
    
    private let commandsRepository: CommandsRepository
    
    init(commandsRepository: CommandsRepository = IoC.shared.resolveOrNil()!) {
        self.commandsRepository = commandsRepository
    }
    
    func invoke(command: Command) {
        commandsRepository.deleteCommand(cmd: command)
    }
    
}
