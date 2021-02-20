//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 10/02/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import CoreData

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
