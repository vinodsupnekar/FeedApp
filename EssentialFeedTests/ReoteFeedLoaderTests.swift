//
//  ReoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by PlayerzPotMedia on 16/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class ReoteFeedLoaderTests: XCTestCase {
    
  //Commit:- remote feed loader does not request data on creation
  func test_init_doesNotRequestDataFromURL() {
    let url = URL(string: "http://a-given-url.com")!
    let (client,_) = makeSUT(url: url)
//    HTTPClient.shared = client
      XCTAssertNil(client.requestedURL)
  }
 
 // Use case:- Load feed items
  
  func test_load_requestsDataFromURL() {
      let url = URL(string: "http://a-given-url.com")!
     let (client,sut) = makeSUT(url: url)
     sut.load()
     //When we sut.load(), then we we will havd client with requestedURL
     XCTAssertEqual(url,client.requestedURL)
   }
  
  func test_loadTwice_requestsDataFromURL() {
     let url = URL(string: "http://a-given-url.com")!
    let (client,sut) = makeSUT(url: url)
    sut.load()
     sut.load()
    //When we sut.load(), then we we will havd client with requestedURL
    XCTAssertEqual(client.requestedURLs,[url,url])
  }
  
   
  
  private func makeSUT(url: URL =  URL(string: "http://a-given-url.com")!) -> (HTTPClientSpy, RemoteFeedLoader) {
      let client = HTTPClientSpy()
      let sut = RemoteFeedLoader(url: url,client: client)
    return (client,sut)
  }
  
 private class HTTPClientSpy: HTTPClient {
   var requestedURL: URL?
 var requestedURLs = [URL]()
   
    func get(from url: URL) {
     requestedURL = url
     requestedURLs.append(url)
   }
 }

}

