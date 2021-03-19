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
        deletionCompletions[index](.failure(error))
    }
    
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](.success(Void()))
    }
    
    func completeInsertionSuccessfully(at index:Int = 0) {
        insertionCompletions[index](.success(Void()))
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion : @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error : Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with error : Error, at index: Int = 0) {
        retrieveCompletion[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrieveCompletion[index](.success(.none))
    }
        
    func retrieve(completion: @escaping RetrievalCompletion) {
        retrieveCompletion.append(completion)
        recievedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with feed : [LocalFeedImage],timestamp: Date, at index: Int = 0) {
        retrieveCompletion[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
}
