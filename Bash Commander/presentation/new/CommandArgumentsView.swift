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
	
	private let disposeBag = DisposeBag()
	
	let window: NSWindow
	let cmd: Command
	private let executeCommand: ExecuteCommand
	private let getCommands: GetCommands
	
	@State private var arguments: String = ""
	@State private var cmdText: String?
	
	init(
		window: NSWindow,
		cmd: Command,
		getCommands: GetCommands = IoC.shared.resolveOrNil()!,
		executeCommand: ExecuteCommand = IoC.shared.resolveOrNil()!
	) {
		self.window = window
		self.cmd = cmd
		self.getCommands = getCommands
		self.executeCommand = executeCommand
		self.cmdText = cmd.command
	}
	
	private func subscribeToGetCommands() {
		getCommands.invoke().subscribe { commands in
			guard let thisCmd = commands.element?.values
					.flatMap({$0})
					.first(where: {$0 == self.cmd })
			else {
				return window.close()
			}
			cmdText = thisCmd.command
		}.disposed(by: disposeBag)
	}
	
	private func onCommit() {
		if arguments.isEmpty {return}
		executeCommand.invoke(cmd, arguments: arguments)
		close()
	}
	
	private func close() {
		window.close()
	}
	
	var body: some View {
		HStack(spacing: 8) {
			Text(cmdText ?? "")
			TextField("arguments", text: $arguments.animation(), onCommit: onCommit).textFieldStyle(MyTextStyle())
		}
		.padding(.all, 8)
		.background(Color.background)
		.onAppear(perform: subscribeToGetCommands)
	}
	
	
}
