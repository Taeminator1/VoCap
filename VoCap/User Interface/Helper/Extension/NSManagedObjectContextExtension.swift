//
//  NSManagedObjectContextExtension.swift
//  VoCap
//
//  Created by 윤태민 on 8/20/21.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func saveContext() {
        do {
            try self.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
