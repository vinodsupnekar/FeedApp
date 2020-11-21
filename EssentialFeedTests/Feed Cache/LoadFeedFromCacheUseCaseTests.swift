//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private class FeedStoreSpy: FeedStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void

        enum RecievedMessage : Equatable{
            case deleteCachedFeed
            case insert([LocalFeedImage],Date)
        }
        private(set) var recievedMessages = [RecievedMessage]()
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [DeletionCompletion]()

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
    }
    
}

