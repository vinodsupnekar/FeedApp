//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 01/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func deleteCacheFeed(completion : @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion : @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
