//
//  AppConfig.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation

protocol AppConfig {
    var version : String { get }
    var gitHubRepo: String { get }
}

class AppConfigImpl : AppConfig {
    
    var version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    var gitHubRepo: String = "Ownii/Bash-Commander"
    
}
