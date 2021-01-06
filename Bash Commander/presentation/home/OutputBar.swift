//
//  OutputBar.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI

struct OutputBar: View {
    @EnvironmentObject var navigator: Navigator
    
    let output: CommandOutput
    
    var body: some View {
        Group {
            HStack {
                showText()
                Spacer()
                if( output.output != nil || output.state == CommandState.RUNNING ) {
                    showAction()
                }
            }
            .padding(8)
        }
        .background(getColor())
        .frame(maxWidth: .infinity)
    }
    
    private func showAction() -> IconButton {
            switch output.state {
            case .SUCCEEDED:
                return IconButton(name: "output", hoverColor: Color.white.opacity(0.75), action: openOutput)
            case .FAILED:
                return IconButton(name: "error", hoverColor: Color.white.opacity(0.75), action: openOutput)
            default:
                return IconButton(name: "close", hoverColor: Color.white.opacity(0.75)) {
                    output.task?.interrupt()
                }
            }
    }
    
    private func openOutput() {
        navigator.open(width: 700, height: 400) { window in
            OutputView(output: output.output ?? "", window: window)
        }
    }
    
    private func showText() -> Text {
        switch output.state {
        case .SUCCEEDED:
            return Text("succeeded")
        case .FAILED:
            return Text("error")
        default:
            return Text("running")
        }
    }
    
    private func getColor() -> Color {
        switch output.state {
        case .SUCCEEDED:
            return .success
        case .FAILED:
            return .error
        default:
            return .card
        }
    }
}
