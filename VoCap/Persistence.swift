//
//  Persistence.swift
//  VoCap
//
//  Created by 윤태민 on 11/24/20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0 ..< 10 {
            let newItem = Note(context: viewContext)
            newItem.colorIndex = Int16(Int.random(in: 0 ..< Pallet.colors.count))
            newItem.id = UUID()
            newItem.isAutoCheck = Bool.random()
            newItem.isWidget = Bool.random()
            newItem.memo = "memo \(i)"
            newItem.memorizedNumber = Int16(Int.random(in: 0 ..< 100))
            newItem.order = Int16(i)
            newItem.title = "title \(i)"
            newItem.totalNumber = Int16(Double(newItem.memorizedNumber) * Double.random(in: 1 ..< 2))
            
            newItem.term.append("dd")
            newItem.definition.append("aa")
            newItem.isMemorized.append(false)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "VoCap")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
