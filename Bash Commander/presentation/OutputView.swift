//
//  OutputView.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI
import RxSwift

struct OutputView: View {
    
    private let disposeBag = DisposeBag()
    
    let output: Observable<String>
    let window: NSWindow
    
    @State var content: String = ""
    
    var body: some View {
        ReverseScrollView {
            Text(content.trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(8)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, alignment: .bottomLeading).onAppear {
            output.subscribe(onNext: { content in
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
