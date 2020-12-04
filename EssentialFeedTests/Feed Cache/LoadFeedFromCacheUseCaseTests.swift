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
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local,timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThansevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: moreThansevenDaysOldTimestamp)
        }
    }
    
    func test_load_deletesCacheOnRetrievalError() {
        let (sut,store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.recievedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_load_doesNotDeletesCacheOnEmptyCache() {
        let (sut,store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve])
    }
    
    func test_load_deleteCacheOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut,store) = makeSUT(currentDate: {fixedCurrentDate})

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        XCTAssertEqual(store.recievedMessages, [.retrieve,.deleteCachedFeed])
 
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

    private func anyNSError() -> NSError {
      return NSError(domain: "my error", code: 1)
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func anyURL() -> URL {
      return URL(string: "www.any-url.com")!
    }
    
    private func uniqueImageFeed() -> (models : [FeedImage] , local: [LocalFeedImage]) {
        let models = [uniqueImage(),uniqueImage()]
        let localItems = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
        return (models,localItems)
    }
    
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

