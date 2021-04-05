//
//  CommandArgumentsView.swift
//  Bash Commander
//
//  Created by Igor Fedotov on 17.03.21.
//

import SwiftUI
import Swift_IoC_Container
import RxSwift

struct CommandArgumentsView: View {
	
	let window: NSWindow
	let cmd: Command
	private let executeCommand: ExecuteCommand
	
    @State private var arguments: [String:String] = [:]
    	
	init(
		window: NSWindow,
		cmd: Command,
		executeCommand: ExecuteCommand = IoC.shared.resolveOrNil()!
	) {
		self.window = window
		self.cmd = cmd
		self.executeCommand = executeCommand
	}
	

	
	private func onCommit() {
		if !isValid() {return}
		executeCommand.invoke(cmd, arguments: arguments)
		close()
	}
	
	private func close() {
		window.close()
	}
	
	var body: some View {
        VStack {
            ForEach(cmd.getArguments(), id: \.self) { argument in
                TextField(argument, text: Binding<String>(
                            get: { self.arguments[argument] ?? "" },
                            set: { self.arguments[argument] = $0}).animation(),
                          onCommit: onCommit).textFieldStyle(MyTextStyle())
                    .focusable()
            }
            MaterialButton(text: "execute", enabled: isValid(), action: onCommit)
        }
		.padding(.all, 8)
		.background(Color.background)
	}
    
    func isValid() -> Bool {
        cmd.getArguments().allSatisfy { argument in
            !(self.arguments[argument]?.isBlank() ?? true)
        }
    }
	
	
}
