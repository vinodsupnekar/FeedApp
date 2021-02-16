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
    
//    public init(storeURL: URL, bundle: Bundle = .main) throws {
//        NSPersistentContainer.load()
//        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
//        context = container.newBackgroundContext()
//    }
    public init( storeURL: URL, bundle : Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL,in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        completion(.empty)
//        perform { context in
//            do {
//                if let cache = try ManagedCache.find(in: context) {
//                    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
//                } else {
//                    completion(.empty)
//                }
//            } catch {
//                completion(.failure(error))
//            }
//
//        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
//        perform { context in
//            do {
//                let managedCache = try ManagedCache.newUniqueInstance(in: context)
//                managedCache.timestamp = timestamp
//                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
//
//                try context.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
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

private class ManagedCache: NSManagedObject {
    @NSManaged  var timestamp: Date
    @NSManaged  var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
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
    
    static func load(modelName name:String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.with(name: name,in : bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
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


