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
    
}

