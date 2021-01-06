//
//  OutputView.swift
//  Bash Commander
//
//  Created by Martin Förster on 05.01.21.
//

import SwiftUI

struct OutputView: View {
    
    let output: String
    let window: NSWindow
    
    var body: some View {
        ScrollView {
            Text(output.trimmingCharacters(in: .whitespacesAndNewlines))
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .padding(8)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, alignment: .bottomLeading)
    }
}
