//
//  AddCommandView.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI
import Swift_IoC_Container
import RxSwift

struct MyTextStyle : TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
       configuration
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .textFieldStyle(PlainTextFieldStyle())
        .background(Color.card)
        .foregroundColor(.defaultText)
        .cornerRadius(6)
   }
}

extension NSTextField {
        open override var focusRingType: NSFocusRingType {
                get { .none }
                set { }
        }
}

struct EditCommandView: View {
    
    private let disposeBag = DisposeBag()
    
    let window: NSWindow
    let cmd: Command?
    
    private let addCommand: AddComand
    private let getGroups: GetGroups
    private let deleteCommand: DeleteCommand
    private let editCommand: EditCommand
       
    @State private var name: String = ""
    @State private var command: String = ""
    @State private var path: String = "~"
    @State private var group: Int = 0
    @State private var groupName: String = ""
    
    @State private var groups: [String] = []
    
    init(
        window: NSWindow,
        cmd: Command?,
        addCommand: AddComand = IoC.shared.resolveOrNil()!,
        getGroups: GetGroups = IoC.shared.resolveOrNil()!,
        deleteCommand: DeleteCommand = IoC.shared.resolveOrNil()!,
        editCommand: EditCommand = IoC.shared.resolveOrNil()!
    ) {
        self.window = window
        self.cmd = cmd
        self.addCommand = addCommand
        self.getGroups = getGroups
        self.deleteCommand = deleteCommand
        self.editCommand = editCommand
    }
    
    private func getGroupName() -> String {
        if( group > 0 ) {
            return groups[group-1]
        }
        else {
            return self.groupName
        }
    }
    
    private func onAppear() {
        name = cmd?.name ?? ""
        command = cmd?.command ?? ""
        path = cmd?.path ?? "~"
        groupName = cmd?.group ?? ""
        
        getGroups.invoke().subscribe { groups in
            self.groups = groups.element ?? []
            if let groupName = self.cmd?.group {
                if let index = self.groups.firstIndex(of: groupName) {
                    self.group = index+1
                }
                
            }
        }.disposed(by: disposeBag)
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                TextField("name", text: $name.animation())
                    .textFieldStyle(MyTextStyle())
                    .focusable()
                TextField("command", text: $command.animation())
                    .textFieldStyle(MyTextStyle())
                    .focusable()
                HStack {
                    TextField("path", text: $path.animation()).disabled(true)
                        .textFieldStyle(MyTextStyle())
                        .tooltip($path.wrappedValue)
                    IconButton(name: "more") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        if( panel.runModal() == .OK) {
                            path = panel.url?.path ?? ""
                        }
                    }
                }
                Picker(selection: $group.animation(), label: Text("group")) {
                    Text("newGroup").tag(0)
                    ForEach(groups, id: \.self) { group in
                        Text(group).tag(groups.firstIndex(of: group)!+1)
                    }
                }
                if( group == 0 ) {
                    TextField("groupname", text: $groupName.animation())
                        .textFieldStyle(MyTextStyle())
                        .focusable()
                }
            }
            
            Spacer()
            if( cmd != nil ) {
                HStack {
                    MaterialButton(text: "remove", color: .error) {
                        deleteCommand.invoke(command: cmd!)
                        window.close()
                    }
                    MaterialButton(text: "save", enabled: isValid()) {
                        editCommand.invoke(cmd!, name: name, path: path, command: command, group: getGroupName())
                        window.close()
                    }
                }
            }
            else {
                MaterialButton(text: "add", enabled: isValid()) {
                    addCommand.invoke(name: name, path: path, command: command, group: getGroupName())
                    window.close()
                }
            }
        }
        .padding(.all, 8)
        .background(Color.background)
        .onAppear {
           onAppear()
        }
    }
    
    func isValid() -> Bool {
        return !name.isBlank() && !command.isBlank() && !path.isBlank() && (group > 0 || !groupName.isBlank())
    }
}

extension String {
    func isBlank() -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
