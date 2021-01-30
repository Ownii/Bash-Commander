//
//  GetGroups.swift
//  Bash Commander
//
//  Created by Martin Förster on 13.11.20.
//

import Foundation
import Swift_IoC_Container
import RxSwift

protocol GetGroups {
    func invoke() -> Observable<[String]>
}

class GetGroupsImpl : GetGroups {
    
    private let commandsRepository: CommandsRepository
    
    init(commandsRepository: CommandsRepository = IoC.shared.resolveOrNil()!) {
        self.commandsRepository = commandsRepository
    }
    
    func invoke() -> Observable<[String]> {
        return commandsRepository.getCommands().map { commands in
            let groups = commands.map { $0.group }.compactMap { $0 }.sorted().distinct()
            return groups
        }
    }
        
}
