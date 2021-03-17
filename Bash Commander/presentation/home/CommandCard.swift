//
//  CommandCard.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import SwiftUI
import Swift_IoC_Container

struct CommandCard: View {
    
    @EnvironmentObject var navigator: Navigator
    
    let command: Command
    let executeCommand: ExecuteCommand
    init(
        _ command: Command,
        executeCommand: ExecuteCommand = IoC.shared.resolveOrNil()!
    ) {
        self.command = command
        self.executeCommand = executeCommand
    }
    
    func onExecuteCommand() {
        executeCommand.invoke(command)
    }
    
    func onMorePressed() {
        navigator.open { window in
            EditCommandView(window: window, cmd: command)
        }
    }
	
	func onExecuteWithArgs() {
		navigator.open(width: 450, resizable: true) { window in
			CommandArgumentsView(window: window, cmd: command)
		}
	}
    
    var body: some View {
        Group {
            HStack {
                Text(command.name!)
                    .fontWeight(.medium)
                Spacer()
                IconButton(name: "edit", action: onMorePressed)
                IconButton(name: "execute", action: onExecuteCommand)
				IconButton(name: "execute_plus", action: onExecuteWithArgs)
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 8)
            .background(Color.card)
        }
        .cornerRadius(4)
        .overlay(RoundedRectangle(cornerRadius: 4).fill(Color.transparent))
    }
}
