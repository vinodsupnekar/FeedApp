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
    
    //MARK: Helpers
    
    private func makeSUT( currentDate: @escaping ()  -> Date = Date.init ,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader,store: FeedStoreSpy){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store, currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func anyNSError() -> NSError {
      return NSError(domain: "my error", code: 1)
    }
    
}
