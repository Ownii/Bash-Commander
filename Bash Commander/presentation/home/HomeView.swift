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
    
    private let getExecutionState: GetExecutionState
    
    init(getExecutionState: GetExecutionState = IoC.shared.resolveOrNil()!) {
        self.getExecutionState = getExecutionState
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
                        DispatchQueue.main.async {
                            let appDelegate = NSApplication.shared.delegate as! AppDelegate
                            appDelegate.updateStatusBarIcon(.normal)
                        }
                    }
                })
            }
        }
        .background(Color.background)
        .frame(maxWidth: .infinity)
        .onAppear {
            getExecutionState.invoke()
                .flatMap { state -> Observable<Bool> in
                    withAnimation {
                        showBar = true
                    }
                    
                    var icon: StatusBarIcon
                    switch(state) {
                    case .SUCCEEDED:
                        icon = StatusBarIcon.succeeded
                    case .FAILED:
                        icon = StatusBarIcon.failed
                    case .RUNNING:
                        icon = StatusBarIcon.running
                    }
                    
                    DispatchQueue.main.async {
                        let appDelegate = NSApplication.shared.delegate as! AppDelegate
                        appDelegate.updateStatusBarIcon(icon)
                    }
                    
                    if( state == ExecutionState.RUNNING ) {
                        return Observable.just(false)
                    }
                    else {
                        return Observable.just(true)
                    }
                }
                .debounce(.seconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: { hide in
                    if( hide ) {
                        DispatchQueue.main.async {
                            let appDelegate = NSApplication.shared.delegate as! AppDelegate
                            appDelegate.updateStatusBarIcon(.normal)
                        }
                        withAnimation {
                            self.showBar = false
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}
