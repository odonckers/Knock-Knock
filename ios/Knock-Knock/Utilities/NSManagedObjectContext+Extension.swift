//
//  NSManagedObjectContext+Extension.swift
//  Knock-Knock
//
//  Created by Owen Donckers on 2/19/21.
//

import CoreData

extension NSManagedObjectContext {
    public func unsafeSave() {
        if hasChanges {
            do {
                try save()
            } catch {
                /*
                 Replace this implementation with code to handle the error
                 appropriately.
                 
                 fatalError() causes the application to generate a crash log and
                 terminate. You should not use this function in a shipping
                 application, although it may be useful during development.
                 */
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
