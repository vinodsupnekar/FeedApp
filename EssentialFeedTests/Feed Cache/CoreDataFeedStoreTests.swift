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
        let sut = makeSUT()
        
        assertThatRetrievelDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrievehHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT(url: noDeletePermissionURL())
        assertThatDeleteDeliversErrorOnDeletionError(on: sut, store: noDeletePermissionURL())
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut =  makeSUT(url: noDeletePermissionURL())
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut =  makeSUT(url: noDeletePermissionURL())
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut =  makeSUT(url: noDeletePermissionURL())
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunsSerially(on: sut)
    }
    
    func test_storeSideEffects_runSerially_withInsert_Retrieve() {
        let sut = makeSUT()
        
        assertThatSideEffectsRunsSerially(on: sut)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line,url: URL) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("aasas.txt")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(sut)
        return sut
    }
    
    private func noDeletePermissionURL() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        return try! FileManager.default.url(for: NSTemporaryDirectory(), in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("aasas.txt")
        }
}
