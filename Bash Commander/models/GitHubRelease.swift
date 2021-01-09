//
//  GitHubRelease.swift
//  Bash Commander
//
//  Created by Martin Förster on 09.01.21.
//

import Foundation

struct GitHubRelease : Decodable {
    let html_url: String
    let tag_name: String
    let target_commitish: String
    let draft: Bool
    let name: String
    let body: String
}
