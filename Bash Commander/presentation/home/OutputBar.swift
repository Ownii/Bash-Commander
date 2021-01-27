//
//  OutputBar.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI
import RxSwift

struct OutputBar: View {
    @EnvironmentObject var navigator: Navigator
    
    let output: Observable<String>
    let hide: () -> Void
    
    var body: some View {
        Group {
            HStack {
                showText()
                Spacer()
                IconButton(name: "output", hoverColor: Color.white.opacity(0.75), action: openOutput)
                IconButton(name: "close", hoverColor: Color.white.opacity(0.75)) {
                    output.task?.interrupt()
                    hide()
                }
                
            }
            .padding(8)
        }
        .background(getColor())
        .frame(maxWidth: .infinity)
    }
    
    private func openOutput() {
        navigator.open(width: 700, height: 400) { window in
            OutputView(window: window)
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
