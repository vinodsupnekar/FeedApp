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
    let url = URL(string: "http://a-given-url.com")!
    let (client,_) = makeSUT(url: url)
//    HTTPClient.shared = client
      XCTAssertNil(client.requestedURL)
  }
 
 // Use case:- Load feed items
  func test_load_requestDataFromURL() {
     let url = URL(string: "http://a-given-url.com")!
    let (client,sut) = makeSUT(url: url)
    sut.load()
    //When we sut.load(), then we we will havd client with requestedURL
    XCTAssertEqual(url,client.requestedURL)
  }
  
  private func makeSUT(url: URL =  URL(string: "http://a-given-url.com")!) -> (HTTPClientSpy, RemoteFeedLoader) {
      let client = HTTPClientSpy()
      let sut = RemoteFeedLoader(url: url,client: client)
    return (client,sut)
  }
  
 private class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    
     func get(from url: URL) {
      requestedURL = url
    }
  }

}

