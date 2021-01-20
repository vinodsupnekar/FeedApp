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
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
        expect(sut, toRetrieve: expectedResult, file: file,line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult:RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
}
