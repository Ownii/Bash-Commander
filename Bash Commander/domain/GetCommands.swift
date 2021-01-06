//
//  GetCommands.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import Foundation
import Swift_IoC_Container
import CoreData
import RxSwift

protocol GetCommands {
    func invoke() -> Observable<[String: [Command]]>
}

class GetCommandsImpl : GetCommands {
    
    
    let commandsRepository: CommandsRepository
    
    init(commandsRepository: CommandsRepository = IoC.shared.resolveOrNil()!) {
        self.commandsRepository = commandsRepository
    }
    
    func invoke() -> Observable<[String: [Command]]> {
        return commandsRepository.getCommands().map { commands in
            Dictionary(grouping: commands, by: { $0.group! })
        }
    }
    
}
