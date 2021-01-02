//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 14/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
         
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed,latestTimestamp), to: sut)
        
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string:"invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed,timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionEmptyCache() {
        let sut = makeSUT()
        var deletionError: Error?
        let exp = expectation(description: "wait for cache deletion")

        sut.deleteCacheFeed(completion: { error in
            deletionError = error
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffectsOnDeletingCache() {
        let sut = makeSUT()
        var deletionError: Error?
        let exp = expectation(description: "wait for cache deletion")
        
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        sut.deleteCacheFeed(completion: { error in
            deletionError = error
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let invalidStoreURL = cacheDirectory()
        print("cache directory = \(invalidStoreURL)")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let exp = expectation(description: "wait for cache deletion")
        var deletionError: Error?
        sut.deleteCacheFeed(completion: {error in
                deletionError = error
                exp.fulfill()
            })
        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with an error")
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    // - MARK: Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {

        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func cacheDirectory() -> URL {
        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDirectoryPath = arrayPaths[0]
        return cacheDirectoryPath
      }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut:FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache retrieval")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { recievedInsertionError in
            insertionError = recievedInsertionError
            exp.fulfill()
        }
        wait(for:[exp],timeout: 1.0)
        return insertionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult:RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrival")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty,.empty),(.failure, .failure):
                  break
                    
                case let (.found(expected), .found(retrived)):
                    XCTAssertEqual(retrived.feed, expected.feed, file: file, line: line)
                    XCTAssertEqual(retrived.timestamp, expected.timestamp, file: file, line: line)
                default:
                    XCTFail("expected to retrieve \(expectedResult), got \(retrievedResult) instead",file: file, line: line)
                }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL{
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    
}