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
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
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
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed =  ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {

        let context = self.context
        context.perform {
            do {
                try ManagedCache.find(in: context).map { (obj) -> Void in
                    context.delete(obj)
                }.map({
                    try context.save()
                })
                completion(nil)
//                try ManagedCache.find(in: context).map(context.delete(<#T##object: NSManagedObject##NSManagedObject#>)).map(context.save)
//                    completion(nil)
            }
            catch {
                    completion(error)
            }
        }
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
    @NSManaged  var timestamp: Date
    @NSManaged  var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
            try ManagedCache.find(in: context).map { (obj) -> Void in
                context.delete(obj)
            }
            return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache> (entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}
//
@objc(ManagedFeedImage)
public class ManagedFeedImage: NSManagedObject {
   
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
    
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
    
    var local: LocalFeedImage {
        return LocalFeedImage(id: id, description: imageDescription, location: location, imageURL: url)
    }

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


