//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 07/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//
import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.recievedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut,store) = makeSUT()
        
        sut.validateCache ()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.recievedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeletesCacheOnEmptyCache() {
        let (sut,store) = makeSUT()
        sut.validateCache ()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_validateCache_deletesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_OnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteInvalidCacheAftreSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    //MARK: Helpers
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
}


