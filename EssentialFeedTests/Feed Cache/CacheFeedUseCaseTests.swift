//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 21/10/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items:[FeedItem]) {
        store.deleteCacheFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCacheFeed() {
        deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests : XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store:store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
        
    }
    
    func test_save_requestCacheDeletion() {
            let store = FeedStore()
            let sut = LocalFeedLoader(store:store)
            let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    
    // MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
       return URL(string: "www.any-url.com")!
     }
    
}
