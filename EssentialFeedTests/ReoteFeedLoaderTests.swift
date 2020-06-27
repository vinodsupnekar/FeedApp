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
    
    let (client,sut) = makeSUT()
    expect(sut, toCompleteWith: .failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
             client.complete(with: clientError)
    })
  }
  
  func test_load_deliversErrorsOnNon200HTTPResponse() {
    
    //Arrange:- Given the sut and it's HTTP client spy
    let (client,sut) = makeSUT()
    
    //Act:- When we tell the sut to load and we complete the client's HTTP Request with an error
    let samples = [199,201,300,400,500]
    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: .failure(.invalidData)) {
              client.complete(withStatusCode: code,at: index)
      }
    }
    
  }
  
  func test_load_deliversErrorOn200responseWithInvalidJSON(){
       let (client,sut) = makeSUT()
   
    expect(sut, toCompleteWith: .failure(.invalidData)) {
       let invalidJSON = Data(bytes: "invalid json".utf8)
              client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (client,sut) = makeSUT()
  
    expect(sut, toCompleteWith: .success([])) {
      let emptyListJSON = Data(bytes: "{\"items\":[]}".utf8)
         client.complete(withStatusCode: 200, data: emptyListJSON)
    }
  
  }
  
  func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
    let (client,sut) = makeSUT()
    
    let feedItem1 = makeItem(id: UUID(),description: nil,location: nil,imageURL: URL(string: "http://www.google.com")!)
        
    let feedItem2 = makeItem(id: UUID(),description: "a description",location: "a location",imageURL: URL(string: "http://www.google.com")!)
    let items = [feedItem1.model,feedItem2.model]
    
    expect(sut, toCompleteWith: .success(items), when: {
        let json = makeItemsJSON([feedItem1.json,feedItem2.json])
        client.complete(withStatusCode: 200, data: json)
      })
   
  }
}

private func makeItemsJSON(_ items:[[String:Any]]) -> Data {
  let json = ["items":items]
  return try! JSONSerialization.data(withJSONObject: json)
}

private func expect(_ sut:RemoteFeedLoader,toCompleteWith result:RemoteFeedLoader.Result,file: StaticString = #file,line: UInt = #line,when action:() -> Void) {
  
    var capturedErrors = [RemoteFeedLoader.Result]()
  
    sut.load {
           capturedErrors.append($0)
       }
       action()
  XCTAssertEqual(capturedErrors,[result],file: file,line: line)
}

  private func makeSUT(url: URL =  URL(string: "http://a-given-url.com")!) -> (HTTPClientSpy, RemoteFeedLoader) {
      let client = HTTPClientSpy()
      let sut = RemoteFeedLoader(url: url,client: client)
    return (client,sut)
  }

private func makeItem(id: UUID, description: String? = nil,location: String? = nil,imageURL: URL) -> (model: FeedItem, json: [String:Any]) {
  let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
  let json = ["id":id.uuidString,
              "description":description,
              "location":location,
              "image":imageURL.absoluteString].reduce(into: [String:Any]()) { (acc,e) in
                if e.value != nil { acc[e.key] = e.value }
                }
  return (item,json)
}

 private class HTTPClientSpy: HTTPClient {
  var requestedURLs: [URL] {
    return messeges.map { $0.url }
  }

  private var messeges = [(url: URL, completion: (HTTPClientResult) -> Void)]()
  
  func get(from url: URL,completion: @escaping ((HTTPClientResult) -> Void)) {
      messeges.append((url,completion))
  }
  
  func complete(with error:Error,at index:Int = 0) {
    messeges[index].completion(.failure(error))
  }
  
  func complete(withStatusCode code:Int,data:Data = Data(), at index:Int = 0) {
    let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
    messeges[index].completion(.success(data,response))
  }
  



}

