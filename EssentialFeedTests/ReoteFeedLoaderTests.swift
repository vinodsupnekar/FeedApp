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
    
    }
    
  }

  class HTTPClient {
    var requestedURL: URL?
  }
  
  //Commit:- remote feed loader does not request data on creation
  func test_init_doesNotRequestDataFromURL() {
    _ = RemoteFeedLoader()
      let client = HTTPClient()
      XCTAssertNil(client.requestedURL)
  }
 
  //Use case:- Load feed items
//  func test_load_requestDataFromURL() {
//    let client = HTTPClient()
//    let sut = RemoteFeedLoader()
//
//    sut.load()
//
//    //When we sut.load(), then we we will havd client with requestedURL
//    XCTAssertNotNil(client.requestedURL)
//  }

}
