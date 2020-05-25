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
     XCTAssertTrue(client.requestedURLs.isEmpty)
  }
 
 // Use case:- Load feed items
  
  func test_load_requestsDataFromURL() {
      let url = URL(string: "http://a-given-url.com")!
     let (client,sut) = makeSUT(url: url)
     sut.load(){ _ in  }
     //When we sut.load(), then we we will havd client with requestedURL
     XCTAssertEqual(client.requestedURLs,[url])
   }
  
  func test_loadTwice_requestsDataFromURL() {
     let url = URL(string: "http://a-given-url.com")!
    let (client,sut) = makeSUT(url: url)
    sut.load(){ _ in  }
     sut.load(){ _ in  }
    //When we sut.load(), then we we will havd client with requestedURL
    XCTAssertEqual(client.requestedURLs,[url,url])
  }
  
  func test_load_deliversErrorsonClientError() {
    
    //Arrange:- Given the sut and it's HTTP client spy
    let (client,sut) = makeSUT()
    //Act:- When we tell the sut to load and we complete the client's HTTP Request with an error
    var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {
          capturedErrors.append($0)
        }
    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError)
    
    //Assert:- Then we expect the captured load error to be a connectivity error.
   XCTAssertEqual(capturedErrors,[.connectivity])
  }
  
  func test_load_deliversErrorsOnNon200HTTPResponse() {
    
    //Arrange:- Given the sut and it's HTTP client spy
    let (client,sut) = makeSUT()
    
    //Act:- When we tell the sut to load and we complete the client's HTTP Request with an error
    let samples = [199,201,300,400,500]
    samples.enumerated().forEach { index, code in
      var capturedErrors = [RemoteFeedLoader.Error]()
      
        sut.load {
          capturedErrors.append($0)
      }
      
      client.complete(withStatusCode: code,at: index)
      //Assert:- Then we expect the captured load error to be a connectivity error.
      XCTAssertEqual(capturedErrors,[.invalidData])
    }
    
  }
   
  
  private func makeSUT(url: URL =  URL(string: "http://a-given-url.com")!) -> (HTTPClientSpy, RemoteFeedLoader) {
      let client = HTTPClientSpy()
      let sut = RemoteFeedLoader(url: url,client: client)
    return (client,sut)
  }
  
 private class HTTPClientSpy: HTTPClient {
  var requestedURLs: [URL] {
    return messeges.map { $0.url }
  }

  private var messeges = [(url: URL, completion: (Error?,HTTPURLResponse?) -> Void)]()
  
  func get(from url: URL,completion: @escaping ((Error?,HTTPURLResponse?) -> Void)) {
      messeges.append((url,completion))
  }
  
  func complete(with error:Error,at index:Int = 0) {
    messeges[index].completion(error,nil)
  }
  
  func complete(withStatusCode code:Int, at index:Int = 0) {
    let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)
    messeges[index].completion(nil,response)
  }
 }

}

