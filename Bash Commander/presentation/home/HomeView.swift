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
    
    @EnvironmentObject var navigator: Navigator
    @State var commandOutput: CommandOutput? = nil
    
    private let bashRepository: BashRepository
    
    init(bashRepository: BashRepository = IoC.shared.resolveOrNil()!) {
        self.bashRepository = bashRepository
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
            if( commandOutput != nil ) {
                OutputBar(output: commandOutput!, hide: {
                    withAnimation {
                        self.commandOutput = nil
                    }
                })
            }
        }
        .background(Color.background)
        .frame(maxWidth: .infinity)
        .onAppear {
            bashRepository.getOutput()
                .flatMap { output -> Observable<CommandOutput> in
                withAnimation {
                    self.commandOutput = output
                }
                return Observable.just(output).delay(.seconds(30), scheduler: MainScheduler.instance)
            }
                .subscribe { output in
                    if( output.element?.state != .RUNNING ) {
                        withAnimation {
                            self.commandOutput = nil
                        }
                    }
            }.disposed(by: disposeBag)
        }
    }
}
