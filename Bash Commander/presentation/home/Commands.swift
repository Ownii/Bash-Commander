//
//  Commands.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import SwiftUI
import Swift_IoC_Container
import RxSwift

struct Commands: View {
    
    let disposeBag = DisposeBag()
        
    private let getCommands: GetCommands
    @State private var groups: [String: [Command]] = [:]
    
    init(getCommands: GetCommands = IoC.shared.resolveOrNil()!) {
        self.getCommands = getCommands
    }
    
    var body: some View {
        return VStack {
            ForEach(Array(groups.keys).sorted(), id: \.self) { name in
                CommandSection(name: name, commands: groups[name]!)
            }
        }.onAppear {
            getCommands.invoke().subscribe { commands in
                groups = commands
            }.disposed(by: disposeBag)
        }
    }
}
