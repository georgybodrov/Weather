import CoreData

public class CoreDataStorage {
    
    private enum MemoryType {
        case inMemory
        case persisted
    }
    
    // MARK: Singleton
    
    public static let instance = CoreDataStorage()
    private init() { }
    
    // MARK: Hermes
    
    let weatherPersistedContext = CoreDataStorage.contextWithModelName("WeatherModel", dbName: "WeatherDB", memoryType: .persisted, concurrencyType: .mainQueueConcurrencyType)

    // MARK: - Service
    
    class private func objectModelWith(name: String) -> NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            print("Can't locate object model \(name)")
            abort()
        }
        return NSManagedObjectModel(contentsOf: modelURL)
    }
    
    class private func contextWithModelName(_ modelName: String, dbName: String?, memoryType: MemoryType, concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext? {
        if let model = objectModelWith(name: modelName) {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            if memoryType == .inMemory {
                do {
                    try coordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
                    let context = NSManagedObjectContext(concurrencyType: concurrencyType)
                    context.persistentStoreCoordinator = coordinator
                    return context
                } catch {
                    return nil
                }
            } else {
                if let dbName = dbName, let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
                    let sqliteURL = documentsURL.appendingPathComponent(dbName)
                    let options = [NSInferMappingModelAutomaticallyOption : true, NSMigratePersistentStoresAutomaticallyOption : true]
                    do {
                        if (try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: options)) == nil {
                            // we have failed to migrate automatically
                            try coordinator.destroyPersistentStore(at: sqliteURL, ofType: NSSQLiteStoreType, options: nil)
                            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteURL, options: nil)
                        }
                        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.mergePolicy = NSOverwriteMergePolicy
                        context.persistentStoreCoordinator = coordinator
                        return context
                    } catch {
                        return nil
                    }
                } else {
                    return nil
                }
            }
        } else {
            print("Missing model in \(#function)")
            return nil
        }
        
    }
    
}
