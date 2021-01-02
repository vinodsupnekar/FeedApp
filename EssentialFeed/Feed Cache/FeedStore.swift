//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 01/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, in needed
    func deleteCacheFeed(completion : @escaping DeletionCompletion)
    
    /// The Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, in needed
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion : @escaping InsertionCompletion)
    
    /// The Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, in needed
    func retrieve(completion: @escaping RetrievalCompletion)
}
