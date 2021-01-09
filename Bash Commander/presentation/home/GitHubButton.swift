//
//  GitHubButton.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import SwiftUI
import RxSwift
import Swift_IoC_Container

struct GitHubButton: View {
    
    private let disposableBag = DisposeBag()
    
    private let getReleaseUrl: GetReleaseUrl
    private let isNewVersionAvailable: IsNewVersionAvailable
    
    @State private var newVersionAvailable = false
    
    init(
        getReleaseUrl: GetReleaseUrl = IoC.shared.resolveOrNil()!,
        isNewVersionAvailable: IsNewVersionAvailable = IoC.shared.resolveOrNil()!
         ) {
        self.getReleaseUrl = getReleaseUrl
        self.isNewVersionAvailable = isNewVersionAvailable
    }
    
    var body: some View {
        IconButton(name: "github", badge: newVersionAvailable) {
            getReleaseUrl.invoke().subscribe { url in
                NSWorkspace.shared.open(url)
            }.disposed(by: disposableBag)
        }.onAppear {
            isNewVersionAvailable.invoke().subscribe { isAvailable in
                withAnimation {
                    newVersionAvailable = isAvailable
                }
            }.disposed(by: disposableBag)
        }
    }
}
