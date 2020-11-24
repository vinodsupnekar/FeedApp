//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    enum RecievedMessage : Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage],Date)
        case retrieve
    }
    
    private(set) var recievedMessages = [RecievedMessage]()
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrieveCompletion = [RetrievalCompletion]()
    func deleteCacheFeed(completion : @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        recievedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error : Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion : @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error : Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeRetrieval(with error : Error, at index: Int = 0) {
        retrieveCompletion[index](error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrieveCompletion[index](nil)
    }
        
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrieveCompletion.append(completion)
        recievedMessages.append(.retrieve)
    }

}
