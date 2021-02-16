//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 11/02/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase , FeedStoreSpecs {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrievelDelieversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
    
        assertThatRetrievelHasNoSideEffectsOnEmptyCache(on: sut)
        }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        // AnyClass is:-
        // typealias AnyClass = AnyObject.Type
        // Bundle(for: <#T##AnyClass#>)
        
        let storeBundle = Bundle(for: CoreDataFeedStore.self )// .self)
        let storeURL = URL( fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut)
        return sut
        //        let storeBundle = Bundle(for: CoreDataFeedStore.self)
//        let storeURL = URL(fileURLWithPath: "/dev/null")
//        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
//        trackMemoryLeaks(sut)
//        return sut
    }
}
