//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 01/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation


public typealias CachedFeed  = (feed: [LocalFeedImage],timestamp: Date)

public protocol FeedStore {
    
    typealias RetrievalResult = Result<CachedFeed?,Error>
    
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Error?
    typealias InsertionCompletion = (InsertionResult) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
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
