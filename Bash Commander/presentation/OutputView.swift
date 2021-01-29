//
//  OutputView.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI
import RxSwift
import Swift_IoC_Container

struct OutputView: View {
    
    private let disposeBag = DisposeBag()
    
    let window: NSWindow
    
    private let bashRepository: BashRepository
    
    @State var content: String = ""
    
    init(
        window: NSWindow,
        bashRepository: BashRepository = IoC.shared.resolveOrNil()!
    ) {
        self.window = window
        self.bashRepository = bashRepository
    }
    
    var body: some View {
        ReverseScrollView {
            Text(content.trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(8)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, alignment: .bottomLeading).onAppear {
            bashRepository.executions.flatMap { execution -> Observable<String> in
                return execution
                
            }.subscribe(onNext: { content in
                self.content += content
            }, onError: { error in
                if let bashError = error as? BashError {
                    switch(bashError) {
                    case .workingDirectoryNotExists:
                        self.content += "Working directory does not exist"
                    case .output(let output):
                        self.content += output
                    case .envError(_):
                        self.content = "Error setting up enviroment"
                    case .exit(let exitCode):
                        self.content = "Terminated with exit code \(exitCode)"
                    }
                }
                else {
                    self.content = "Unexpectected error: \(error.localizedDescription)"
                }
            }).disposed(by: disposeBag)
        }
    }
}
