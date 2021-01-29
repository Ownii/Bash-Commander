//
//  OutputBar.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI
import RxSwift
import Swift_IoC_Container


struct OutputBar: View {
    @EnvironmentObject var navigator: Navigator
    
    let disposeBag = DisposeBag()
    
    let hide: () -> Void
    @State private var state: ExecutionState = .RUNNING
    private let cancelRunningExecution: CancelRunningExecution
    private let getCurrentExecution: GetCurrentExecution
    
    init(hide: @escaping () -> Void,
        cancelRunningExecution: CancelRunningExecution = IoC.shared.resolveOrNil()!,
        getCurrentExecution: GetCurrentExecution = IoC.shared.resolveOrNil()!
    ) {
        self.hide = hide
        self.cancelRunningExecution = cancelRunningExecution
        self.getCurrentExecution = getCurrentExecution
    }
    
    var body: some View {
        Group {
            HStack {
                showText()
                Spacer()
                IconButton(name: "output", hoverColor: Color.white.opacity(0.75), action: openOutput)
                IconButton(name: "close", hoverColor: Color.white.opacity(0.75)) {
                    cancelRunningExecution.invoke()
                    hide()
                }
                
            }
            .padding(8)
        }
        .background(getColor())
        .frame(maxWidth: .infinity).onAppear {
            getCurrentExecution.invoke()
                .flatMap { execution -> Observable<String> in
                    withAnimation {
                        state = .RUNNING
                    }
                    return execution.do(onError: { _ in
                        withAnimation {
                            state = .FAILED
                        }
                    },
                    onCompleted: {
                        withAnimation {
                            state = .SUCCEEDED
                        }
                    })
                }.subscribe().disposed(by: disposeBag)
        }
    }
    
    private func openOutput() {
        navigator.open(width: 700, height: 400) { window in
            OutputView(window: window)
        }
    }
    
    private func showText() -> Text {
        switch state {
        case .SUCCEEDED:
            return Text("succeeded")
        case .FAILED:
            return Text("error")
        default:
            return Text("running")
        }
    }
    
    private func getColor() -> Color {
        switch state {
        case .SUCCEEDED:
            return .success
        case .FAILED:
            return .error
        default:
            return .card
        }
    }
}
