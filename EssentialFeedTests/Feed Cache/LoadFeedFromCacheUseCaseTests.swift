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
        let exp = expectation(description: "wait for load completion")
        var recievedError: Error?
        sut.load { result in
            switch result {
            case let .failure(error) :
            recievedError = error
            default:
                XCTFail("Expected failure , got \(result) instead")
        }
        exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(recievedError as NSError? , retrievalError)
    }
    
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

