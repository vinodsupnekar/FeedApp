//
//  ReoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by PlayerzPotMedia on 16/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest

class ReoteFeedLoaderTests: XCTestCase {
  
  class RemoteFeedLoader {
    func load() {
      HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
    
  }

  class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {
    
    }
  }
  
  class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
    override func get(from url: URL) {
      requestedURL = url
    }
  }
  
  //Commit:- remote feed loader does not request data on creation
  func test_init_doesNotRequestDataFromURL() {
    _ = RemoteFeedLoader()
    let client = HTTPClientSpy()
//    HTTPClient.shared = client
      XCTAssertNil(client.requestedURL)
  }
 
 // Use case:- Load feed items
  func test_load_requestDataFromURL() {
    let client = HTTPClientSpy()
       HTTPClient.shared = client

    let sut = RemoteFeedLoader()

    sut.load()

    //When we sut.load(), then we we will havd client with requestedURL
    XCTAssertNotNil(client.requestedURL)
  }

}

/**
 We do not have sigleton any more, and the test logic is now in a test type(Spy)
 
 */
