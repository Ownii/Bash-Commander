//
//  HomeView.swift
//  Bash Commander
//
//  Created by Martin Förster on 12.11.20.
//

import SwiftUI
import Swift_IoC_Container
import RxSwift

struct HomeView: View {
    
    private let disposeBag = DisposeBag()
    private var closeDelay: Disposable? = nil
    
    @EnvironmentObject var navigator: Navigator
    @State var showBar: Bool = false
    
    private let getCurrentExecution: GetCurrentExecution
    
    init(getCurrentExecution: GetCurrentExecution = IoC.shared.resolveOrNil()!) {
        self.getCurrentExecution = getCurrentExecution
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        GitHubButton()
                        IconButton(name: "exit") {
                            NSApplication.shared.terminate(self)
                        }
                    }.padding(.horizontal, 16)
                    .padding(.top, 8)
                    Commands()
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
            }
            Group {
                MaterialButton(text: "add") {
                    navigator.open { window in
                        EditCommandView(window: window, cmd: nil)
                    }
                }
            }
            .padding(.all, 8)
            if showBar {
                OutputBar(hide: {
                    withAnimation {
                        self.showBar = false
                    }
                })
            }
        }
        .background(Color.background)
        .frame(maxWidth: .infinity)
        .onAppear {
            getCurrentExecution.invoke().subscribe(onNext: { execution in
                // TODO: Hide on success/fail after 30 secs
                withAnimation {
                    self.showBar = true
                }
            })
            .disposed(by: disposeBag)
        }
    }
}
