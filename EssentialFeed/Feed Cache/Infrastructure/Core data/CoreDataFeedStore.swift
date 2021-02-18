//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 10/02/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        NSPersistentContainer.load()
        container = try NSPersistentContainer.load(modelName: "FeedStore", storeURL: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
//    public init( bundle : Bundle = .main) throws {
//        container = try NSPersistentContainer.load(modelName: "FeedStore",in: bundle)
//        context = container.newBackgroundContext()
//    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(feed: cache.feed!.compactMap{ ($0 as? ManagedFeedImage) }.map { LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, imageURL: $0.url) }, timestamp: cache.timestamp!))
                }
                else {
                    completion(.empty)
                }
                
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = NSOrderedSet(array:feed.map { local in
                    let managed = ManagedFeedImage(context: context)
                    managed.id = local.id
                    managed.imageDescription = local.description
                    managed.url = local.url
                    managed.location = local.location
                    return managed
                })
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
        
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
//        perform { context in
//            do {
//                try ManagedCache.find(in: context).map(context.delete).map(context.save)
//            } catch {
//                completion(error)
//            }
//        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
//        let context = self.context
//        context.perform {
//            action(context)
//        }
        
    }
}

@objc(ManagedCache)
public class ManagedCache: NSManagedObject {
    @NSManaged  var timestamp: Date?
    @NSManaged  var feed: NSOrderedSet?
}
//
@objc(ManagedFeedImage)
public class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache

}

private extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name:String, storeURL: URL,in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name,in : bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0)}
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0)}
    }
}


