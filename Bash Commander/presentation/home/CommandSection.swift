//
//  CommandSection.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI

struct CommandSection: View {
    
    let name: String
    let commands: [Command]
    
    @State private var isExpanded: Bool = true
    
    init(name: String, commands: [Command]) {
        self.name = name
        self.commands = commands
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
                    
                Spacer()
                IconButton(name: "arrow_down", size: 24) {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
                .rotationEffect(.degrees(isExpanded ? 0 : 180))
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            if( isExpanded ) {
                Group {
                    VStack {
                        ForEach(commands, id: \.id) { command in
                            VStack(spacing: 4) {
                                CommandCard(command)
                                if( commands.last?.id != command.id ) {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.card)
                }
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 4).fill(Color.transparent))
            }
        }
    }
}
