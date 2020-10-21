//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/10/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store:store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
        
    }
    
}
