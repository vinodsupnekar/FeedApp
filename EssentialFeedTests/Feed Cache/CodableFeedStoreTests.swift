////
////  CodableFeedStoreTests.swift
////  EssentialFeedTests
////
////  Created by vinod supnekar on 14/12/20.
////  Copyright © 2020 VinodS. All rights reserved.
////
//
//import XCTest
//import EssentialFeed
//
//class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpec{
//
//    override func setUp() {
//        super.setUp()
//        setUpEmptyStoreState()
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        undoStoreSideEffects()
//    }
//
//    func test_retrieve_deliversEmptyOnEmptyCache() {
//        let sut = makeSUT()
//        assertThatRetrievelDelieversEmptyOnEmptyCache(on: sut)
//    }
//
//    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//        assertThatRetrievelHasNoSideEffectsOnEmptyCache(on: sut)
//    }
//
//    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatRetrievelDeliversFoundValuesOnNonEmptyCache(on: sut)
//    }
//
//
//    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatRetrievelHasNoSideEffectsOnEmptyCache(on: sut)
//    }
//
//    func test_retrieve_deliversFailureOnRetrievalError() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//
//        assertThatRetrievelDeliversFailureOnRetrievalError(on: sut,store: storeURL)
//    }
//
//    func test_retrieve_hasNoSideEffectOnFailure() {
//        let storeURL = testSpecificStoreURL()
//        let sut = makeSUT(storeURL: storeURL)
//        assertThatRetrivelHasNoSideEffectOnFailure(on: sut, store: storeURL)
//    }
//
//    func test_insert_overridesPreviouslyInsertedCachedValues() {
//        let sut = makeSUT()
//
//        let firstInsertionError = insert((uniqueImageFeed().local,Date()), to: sut)
//        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
//
//        let latestFeed = uniqueImageFeed().local
//        let latestTimestamp = Date()
//        let latestInsertionError = insert((latestFeed,latestTimestamp), to: sut)
//
//        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
//        expect(sut, toRetrieve: .success( CachedFeed(feed: latestFeed, timestamp: latestTimestamp)))
//    }
//
//    func test_insert_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
//    }
//
//
//    func test_insert_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
//
//    }
//
//
//    func test_insert_deliversErrorOnInsertionError() {
//        let invalidStoreURL = URL(string:"invalid://store-url")
//        let sut = makeSUT(storeURL: invalidStoreURL)
//        assertThatInsertDeliversErrorOnInsertionError(on: sut)
//    }
//
//    func test_insert_hasNoSideEffectsOnInsertionError() {
//        let invalidStoreURL = URL(string:"invalid://store-url")
//        let sut = makeSUT(storeURL: invalidStoreURL)
//        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//    }
//
//    func test_delete_hasNoSideEffectsOnDeletionEmptyCache() {
//        let noDeletionPermissionURL = cacheDirectory()
//        let sut = makeSUT(storeURL: noDeletionPermissionURL)
//        assertThatDeleteHasNoSideEffectsOnDeletionEmptyCache(on: sut)
//    }
//
//    func test_delete_deliversNoErrorOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
//    }
//
//    func test_delete_hasNoSideEffectsOnEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
//       }
//
//    func test_delete_deliversNoErrorOnNonEmptyCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
//    }
//
//    func test_delete_emptiesPreviouslyInsertedCache() {
//        let sut = makeSUT()
//
//        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
//    }
//
//
//    func test_delete_deliversErrorOnDeletionError() {
//        let invalidStoreURL = cacheDirectory()
//        print("cache directory = \(invalidStoreURL)")
//        let sut = makeSUT(storeURL: invalidStoreURL)
//
//        assertThatDeleteDeliversErrorOnDeletionError(on: sut,store: invalidStoreURL)
//    }
//
//    func test_delete_hasNoSideEffectsDeletionError() {
//        let invalidStoreURL = cacheDirectory()
//        print("cache directory = \(invalidStoreURL)")
//        let sut = makeSUT(storeURL: invalidStoreURL)
//
//        assertThatDeleteHasNoSideEffectsDeletionError(on: sut)
//    }
//
//    func test_storeSideEffects_runSerially() {
//        let sut = makeSUT()
//
//        assertThatSideEffectsRunsSerially(on: sut)
//    }
//
//    // - MARK: Helpers
//
//    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
//
//        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
//        trackMemoryLeaks(sut,file: file,line: line)
//        return sut
//    }
//
//    private func cacheDirectory() -> URL {
//        let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
//        let cacheDirectoryPath = arrayPaths[0]
//        return cacheDirectoryPath
//      }
//
//    private func setUpEmptyStoreState() {
//        deleteStoreArtifacts()
//    }
//
//    private func undoStoreSideEffects() {
//        deleteStoreArtifacts()
//    }
//
//    private func deleteStoreArtifacts() {
//        try? FileManager.default.removeItem(at: testSpecificStoreURL())
//    }
//
//    private func testSpecificStoreURL() -> URL{
//        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
//    }
//
//
//}
