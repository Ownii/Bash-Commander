//
//  EditCommand.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import Foundation
import Swift_IoC_Container

protocol EditCommand {
    func invoke(_ cmd: Command, name: String, path: String, command: String, group: String)
}

class EditCommandImpl : EditCommand {
    
    private let commandsRepository: CommandsRepository
    
    init(commandsRepository: CommandsRepository = IoC.shared.resolveOrNil()!) {
        self.commandsRepository = commandsRepository
    }
    
    func invoke(_ cmd: Command, name: String, path: String, command: String, group: String) {
        cmd.name = name
        cmd.group = group
        cmd.path = path
        cmd.command = command
        commandsRepository.saveChanges()
    }
    
}
