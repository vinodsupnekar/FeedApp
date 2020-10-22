//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/10/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping ()  -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items:[FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
      
    enum RecievedMessage : Equatable{
        case deleteCachedFeed
        case insert([FeedItem],Date)
    }
    private(set) var recievedMessages = [RecievedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
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
    
    func insert(_ items: [FeedItem],timestamp: Date) {
        recievedMessages.append(.insert(items, timestamp))
    }
}

class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
            let items = [uniqueItem(),uniqueItem()]
            let (sut,store) = makeSUT()
        
        sut.save(items)
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
            let items = [uniqueItem(),uniqueItem()]
            let (sut,store) = makeSUT()
            let deletionError = anyNSError()
        
        sut.save(items)
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.recievedMessages,[.deleteCachedFeed,.insert(items, timestamp)])

    }
    
    
    // MARK: - Helpers
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store:FeedStore){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
       return URL(string: "www.any-url.com")!
     }
    
    private func anyNSError() -> NSError {
      return NSError(domain: "my error", code: 1)
    }
    
}
