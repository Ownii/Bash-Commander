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

}

extension Command : Identifiable {

}
