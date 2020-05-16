//
//  ReoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by PlayerzPotMedia on 16/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest

protocol HTTPClient {
//  static var shared = HTTPClient()
  func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
  var requestedURL: URL?
  
   func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoader {
  let client: HTTPClient
  let url: URL
  
  init(url: URL,client: HTTPClient) {
    self.client = client
    self.url = url
  }
  func load() {
    client.get(from: url)
  }
}

class ReoteFeedLoaderTests: XCTestCase {
    
  //Commit:- remote feed loader does not request data on creation
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClientSpy()
    let url = URL(string: "http://a-given-url.com")!

    _ = RemoteFeedLoader(url: url, client: client)
//    HTTPClient.shared = client
      XCTAssertNil(client.requestedURL)
  }
 
 // Use case:- Load feed items
  func test_load_requestDataFromURL() {
    let url = URL(string: "http://a-given-url.com")!
    let client = HTTPClientSpy()
//       HTTPClient.shared = client
    let sut = RemoteFeedLoader(url: url,client: client)

    sut.load()
    //When we sut.load(), then we we will havd client with requestedURL
    XCTAssertEqual(url,client.requestedURL)
  }

}

/**
 We do not have sigleton any more, and the test logic is now in a test type(Spy)
 
 */
