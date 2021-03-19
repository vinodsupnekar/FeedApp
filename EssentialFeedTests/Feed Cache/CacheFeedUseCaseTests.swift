//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/10/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_save_requestCacheDeletion() {
            let (sut,store) = makeSUT()
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
            let (sut,store) = makeSUT()
            let deletionError = anyNSError()
        
        sut.save(uniqueImageFeed().models) { _ in }
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let feed = uniqueImageFeed()
        
        let (sut,store) = makeSUT(currentDate: { timestamp })
        
        sut.save(feed.models) { _ in }
        
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.recievedMessages,[.deleteCachedFeed,.insert(feed.local, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError, when: {
        store.completeDeletion(with:deletionError)

        })
    }
    
    func test_save_failsOnInsertionError() {

        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
          store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    
    }
    
    func test_save_succedsOnSuccessfulCacheInsertion() {

        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) {
            receivedResult.append($0)
        }
        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResult = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models) {
            receivedResult.append($0)
        }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    
    
    // MARK: - Helpers
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut:LocalFeedLoader,toCompleteWithError expectedError: NSError?, when action: ()-> Void,file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save completion")
        
        var recivedError: Error?
        sut.save(uniqueImageFeed().models) { saveResult in
            switch saveResult {
                case .success(_) :
                        break
                case let .failure(error):
                    recivedError = error
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(recivedError as NSError?, expectedError,file: file, line:line)
    }
    
    
}
