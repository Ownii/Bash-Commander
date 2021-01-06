//
//  UseCase.swift
//  Bash Commander
//
//  Created by Martin Förster on 11.11.20.
//

import Foundation

protocol UseCase {
    
    associatedtype ReturnType
    associatedtype ParameterType
    
    func invoke(params: ParameterType) -> ReturnType
}
