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
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
         
        var localFeed: [LocalFeedImage] {
            return feed.map {
                $0.local
            }
        }
    }
    
    private struct CodableFeedImage: Equatable,Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, imageURL: url)
        }
      }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
        
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
       guard let data = try? Data(contentsOf: storeURL) else {
        return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.feed.map { $0.local }, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion : @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map{ CodableFeedImage.init($0)}, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
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
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.insert(feed, timestamp:timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for:[exp],timeout: 1.0)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.insert(feed, timestamp:timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
            switch (firstResult,secondResult) {
            case let (.found(firstFound),.found(secondFound)):
                XCTAssertEqual(firstFound.feed,feed)
                XCTAssertEqual(firstFound.timestamp,timestamp)
                
                XCTAssertEqual(secondFound.feed,feed)
                XCTAssertEqual(secondFound.timestamp,timestamp)
                break
            default:
                XCTFail("Expected retriving twice from non empty cache to deliver same found result with feed \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult)  instead.")
            }
                
            exp.fulfill()
            }
           }
          }
        wait(for:[exp],timeout: 1.0)
    }

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file,line: UInt = #line) -> CodableFeedStore {

        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult:RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrival")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
                case (.empty,.empty):
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
    
    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL{
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    
}
