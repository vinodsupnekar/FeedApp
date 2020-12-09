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
    
    func test_load_requestCacheRetrival() {
        let (sut,store) = makeSUT()
        
        sut.load {_ in }
        
        XCTAssertEqual(store.recievedMessages, [.retrieve]) // Expect to receive retrieve message when sut.load() in invoked
    }
    
    func test_load_failsRetrievalOnError() {
        let (sut,store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local,timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: expirationTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: expiredTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectOnOnRetrievalError() {
        let (sut,store) = makeSUT()
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeletesCacheOnEmptyCache() {
        let (sut,store) = makeSUT()
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults =  [LocalFeedLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    //MARK: Helpers
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action:() -> Void,file: StaticString = #file, line: UInt = #line) {
       
        let exp = expectation(description: "wait for load completion")

        sut.load { recievedResult in
            switch (recievedResult,expectedResult) {
            case let (.success(recievedImages),.success(expectedImages)) :
                XCTAssertEqual(recievedImages, expectedImages,file: file,line: line)
                
            case let (.failure(recievedError as NSError),.failure(expectedError as NSError)) :
                XCTAssertEqual(recievedError, expectedError,file: file,line: line)
            default :
                XCTFail("Expected result \(expectedResult), got \(recievedResult) instead.",file: file,line: line)
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }

    
    
}

