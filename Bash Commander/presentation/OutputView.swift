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
            bashRepository.getOutput().flatMap { output -> Observable<String> in
                return output.output
                
            }.subscribe(onNext: { content in
                self.content += content
            }, onError: { error in
                if let bashError = error as? BashError {
                    self.content = bashError.output
                }
                else {
                    self.content = "Unexpectected error: \(error.localizedDescription)"
                }
            }).disposed(by: disposeBag)
        }
    }
}
