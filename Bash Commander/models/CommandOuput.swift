//
//  CommandOuput.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import Foundation
import RxSwift

enum CommandState {
    case RUNNING
    case SUCCEEDED
    case FAILED
    case EMPTY
}


struct CommandOutput {
    var state: CommandState
    var task: Process?
    var output: Observable<String>
}
