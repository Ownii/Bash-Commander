//
//  ContentView.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import SwiftUI

enum Page : Int {
    case Home = 0
    case New = 1
    case Test = 2
}

struct ContentView: View {
    
    @EnvironmentObject var navigator: Navigator
        
    var body: some View {
        HomeView()
    }
    

}
