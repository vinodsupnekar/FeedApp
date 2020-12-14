//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 14/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty :
                break
            default:
                XCTFail("Expected empty result , got \(result) instead.")
            }
            exp.fulfill()

        }
        wait(for:[exp],timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
            switch (firstResult,secondResult) {
            case (.empty,.empty) :
                break
            default:
                XCTFail("Expected retrieving twice from empty cache to deliever same empty  result , got \(firstResult) and \(secondResult) instead.")
            }
            exp.fulfill()
          }
        }
        wait(for:[exp],timeout: 1.0)
    }

}
