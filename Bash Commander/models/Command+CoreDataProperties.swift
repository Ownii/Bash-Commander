//
//  Command+CoreDataProperties.swift
//  Bash Commander
//
//  Created by Martin Förster on 13.11.20.
//
//

import Foundation
import CoreData


extension Command {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Command> {
        return NSFetchRequest<Command>(entityName: "Command")
    }

    @NSManaged public var command: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var group: String?
    
    public func getArguments() -> [String] {
        guard let cmd = command else { return [] }
        do {
            let regex = try NSRegularExpression(pattern: "\\{(.*?)\\}")
            let arguments = regex.matches(in: cmd, range: NSRange(cmd.startIndex..., in: cmd))
            
            return arguments.map {
                String(cmd[Range($0.range(at: 1), in: cmd)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

}

extension Command : Identifiable {

}
