//
//  AddCommand.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import Foundation
import Swift_IoC_Container

protocol AddComand {
    func invoke(name: String, path: String, command: String, group: String)
}

class AddCommandImpl : AddComand {
    
    let commandsRepository: CommandsRepository
    
    init(commandsRepository: CommandsRepository = IoC.shared.resolveOrNil()!) {
        self.commandsRepository = commandsRepository
    }
    
    func invoke(name: String, path: String, command: String, group: String) {
        _ = commandsRepository.addCommand(name: name, path: path, command: command, group: group)
    }   
    
}
