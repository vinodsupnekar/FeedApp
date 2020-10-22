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
    
    func save(_ items:[FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), completion: { error in
                    completion(error)
                })
            }
            else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    enum RecievedMessage : Equatable{
        case deleteCachedFeed
        case insert([FeedItem],Date)
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
    
    func insert(_ items: [FeedItem],timestamp: Date,completion : @escaping DeletionCompletion) {
        insertionCompletions.append(completion)
        recievedMessages.append(.insert(items, timestamp))
    }
    
    func completeInsertion(with error : Error, at index: Int = 0) {
        insertionCompletions[index](error)
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
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
            let items = [uniqueItem(),uniqueItem()]
            let (sut,store) = makeSUT()
            let deletionError = anyNSError()
        
        sut.save(items) { _ in }
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT(currentDate: { timestamp })
        
        sut.save(items) { _ in }
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.recievedMessages,[.deleteCachedFeed,.insert(items, timestamp)])

    }
    
    func test_save_failsOnDeletionError() {
            let items = [uniqueItem(),uniqueItem()]
            let (sut,store) = makeSUT()
            let deletionError = anyNSError()
        
        let exp = expectation(description: "wait for save completion")
        var recivedError: Error?
        sut.save(items) { error in
            recivedError = error
            exp.fulfill()
        }
        
        store.completeDeletion(with:deletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(recivedError as NSError?, deletionError)
    }
    
    func test_save_failsOnInsertionError() {
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        let exp = expectation(description: "wait for save completion")
        var recivedError: Error?
        sut.save(items) { error in
            recivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(recivedError as NSError?, insertionError)
    }
    
    func test_save_succedsOnSuccessfulCacheInsertion() {
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT()
        
        let exp = expectation(description: "wait for save completion")
        var recivedError: Error?
        sut.save(items) { error in
            recivedError = error
            exp.fulfill()
        }
        
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()

        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(recivedError)
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
