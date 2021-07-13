//
//  Note+CoreDataProperties.swift
//  
//
//  Created by 윤태민 on 6/1/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var colorIndex: Int16
    @NSManaged public var definition: [String]
    @NSManaged public var id: UUID?
    @NSManaged public var isAutoCheck: Bool
    @NSManaged public var isMemorized: [Bool]
    @NSManaged public var isWidget: Bool
    @NSManaged public var memo: String?
    @NSManaged public var memorizedNumber: Int16
    @NSManaged public var order: Int16
    @NSManaged public var term: [String]
    @NSManaged public var title: String?
    @NSManaged public var totalNumber: Int16
    @NSManaged public var d: Int16

}

extension Note : Identifiable {

}

//extension Note {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
//        return NSFetchRequest<Note>(entityName: "Note")
//    }
//
//    @NSManaged public var colorIndex: Int16
//    @NSManaged public var id: UUID?
//    @NSManaged public var isAutoCheck: Bool
//    @NSManaged public var isWidget: Bool
//    @NSManaged public var memo: String?
//    @NSManaged public var memorizedNumber: Int16
//    @NSManaged public var order: Int16
//    @NSManaged public var title: String?
//    @NSManaged public var totalNumber: Int16
//    @NSManaged public var term: [String]
//    @NSManaged public var definition: [String]
//    @NSManaged public var isMemorized: [Bool]
//
//}
//

