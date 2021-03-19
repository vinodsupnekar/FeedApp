//
//  XCTestCase+FeedStore.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 20/01/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrievelDelieversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file:file,line:line)
    }
    
    func assertThatRetrievelHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file:file,line:line)
    }
    
    func assertThatRetrievelDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to:sut)
        
        expect(sut, toRetrieve: .success( .some(CachedFeed(feed: feed, timestamp: timestamp))), file:file,line:line)
    }
    
    func assertThatRetrievehHasNoSideEffectsOnNonEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)))
    }
    
    func assertThatRetrievelDeliversFailureOnRetrievalError(on sut:FeedStore, store storeURL: URL,file: StaticString = #file, line: UInt = #line) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func assertThatRetrivelHasNoSideEffectOnFailure(on sut:FeedStore, store storeURL: URL,file: StaticString = #file, line: UInt = #line) {
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
         
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed,timestamp), to: sut)
        
        XCTAssertNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert((feed,timestamp), to: sut)

        let insertionError2 = insert((feed,timestamp), to: sut)
        
        XCTAssertNil(insertionError2, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert((feed,timestamp), to: sut)

        _ = insert((feed,timestamp), to: sut)
        
        expect(sut, toRetrieve: .success( CachedFeed(feed: feed, timestamp: timestamp)))
//        XCTAssertNil(insertionError2, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed,timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected empty cache deletion to succed")
        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succed")

    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        deleteCache(sut)
        let deletionError1 = deleteCache(sut)

        XCTAssertNil(deletionError1, "Expected empty cache deletion to succed")
    
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        let deletionError = deleteCache(sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succed")
   
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut:FeedStore,file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        deleteCache(sut)

        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut:FeedStore, store storeURL: URL,file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with an error")
    }
    
    func assertThatDeleteHasNoSideEffectsDeletionError(on sut:FeedStore, file: StaticString = #file, line: UInt = #line) {
        
        deleteCache(sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func assertThatSideEffectsRunsSerially(on sut:FeedStore, file: StaticString = #file, line: UInt = #line) {
        var completedOperationInOrder = [XCTestExpectation]()
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) {_ in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCacheFeed { _ in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) {_ in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationInOrder, [op1,op2,op3], "Expected side - effects to run serially but opeartion fiinished in the wrong order")
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut:FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache retrieval")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { recievedInsertionError in
            insertionError = recievedInsertionError
            exp.fulfill()
        }
        wait(for:[exp],timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(_ sut: FeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "wait for cache deletion")

        sut.deleteCacheFeed(completion: { error in
            deletionError = error
            exp.fulfill()
        })
        wait(for: [exp], timeout: 2.0)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult:FeedStore.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrival")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none),.success(.none)),(.failure, .failure):
                  break
                    
            case let (.success(expectedCache), .success(retrivedCached)):
                XCTAssertEqual(retrivedCached?.feed, expectedCache?.feed, file: file, line: line)
                    XCTAssertEqual(retrivedCached?.timestamp, expectedCache?.timestamp, file: file, line: line)
                default:
                    XCTFail("expected to retrieve \(expectedResult), got \(retrievedResult) instead",file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
