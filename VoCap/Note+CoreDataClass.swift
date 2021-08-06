//
//  Note+CoreDataClass.swift
//  
//
//  Created by 윤태민 on 6/1/21.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    var itemCount: Int {
        term.count
    }
    
    func appendItem(_ term: String, _ definition: String, _ itemMemorized: Bool = false) {
        self.term.append(term)
        self.definition.append(definition)
        isMemorized.append(itemMemorized)
    }
    
    func removeItem(atOffsets offsets: IndexSet) {
        self.term.remove(atOffsets: offsets)
        self.definition.remove(atOffsets: offsets)
        self.isMemorized.remove(atOffsets: offsets)
    }
    
    func removeItem(at i: Int) {
        self.term.remove(at: i)
        self.definition.remove(at: i)
        self.isMemorized.remove(at: i)
    }
    
    func findItem(at i: Int) -> (term: String, definition: String, isMemorized: Bool) {
        return (term[i], definition[i], isMemorized[i])
    }
}
