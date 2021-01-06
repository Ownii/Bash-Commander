//
//  CommandOuput.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import Foundation

enum CommandState {
    case RUNNING
    case SUCCEEDED
    case FAILED
}


struct CommandOutput {
    var state: CommandState
    var task: Process?
    var output: String?
}
