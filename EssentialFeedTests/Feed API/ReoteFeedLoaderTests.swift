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
    expect(sut, toCompleteWith: failure(.connectivity), when: {
      let clientError = NSError(domain: "Test", code: 0)
      client.complete(with: RemoteFeedLoader.Error.connectivity)
    })
  }
  
  func test_load_deliversErrorsOnNon200HTTPResponse() {
    
    //Arrange:- Given the sut and it's HTTP client spy
    let (client,sut) = makeSUT()
    
    //Act:- When we tell the sut to load and we complete the client's HTTP Request with an error
    let samples = [199,201,300,400,500]
    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidData)) {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json,at: index)
      }
    }
  }
  
  func test_load_deliversErrorOn200responseWithInvalidJSON(){
       let (client,sut) = makeSUT()
    expect(sut, toCompleteWith: failure(.invalidData)) {
       let invalidJSON = Data(bytes: "invalid json".utf8)
              client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (client,sut) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      let emptyListJSON = makeItemsJSON([])
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

  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let url = URL(string:"http://any-url.com")!
    let client = HTTPClientSpy()
    var sut : RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
    
    var capturedResult = [RemoteFeedLoader.Result]()
    sut?.load {
      capturedResult.append($0)
    }
//    sut?.load(completion: capturedResult.append($0))
    sut = nil
    client.complete(withStatusCode: 200, data: makeItemsJSON([]))
    XCTAssertTrue(capturedResult.isEmpty)
  }
  
  
  
  func test_patternMatching() {
    let leftBool = true
    let rightBool = false
    switch (leftBool,rightBool) {
    case (true,true):
      print("matched both true")
    case (false,false):
      print("matched both true")
    case (_,_):
      print("matched both true")
    }
    
    switch (leftBool, rightBool) {
      case (true, true):
        print("matched both true")

      case (_, _):
        print("matched any case that is not both true with wildcard _")
    }
    
//    switch (leftResult, rightResult) {
//      case (.success(let leftValue), .success(let rightValue)):
//        print("matched both success with leftValue: \(leftValue) and rightValue: \(rightValue)")
//
//      case (.success(let leftValue), .failure(let rightError)):
//        print("matched left success with value: \(leftValue) and right failure with error: \(rightError)")
//
//      case (.failure(let leftError), .success(let rightValue)):
//        print("matched left failure with error: \(leftError) and right success with error: \(rightValue)")
//
//      case (.failure(let leftError), .failure(let rightError)):
//        print("matched both failure with leftError: \(leftError) and rightError: \(rightError)")
//    }
  }
  
  private func makeItemsJSON(_ items:[[String:Any]]) -> Data {
    let json = ["items":items]
    return try! JSONSerialization.data(withJSONObject: json)
  }

  private func expect(_ sut:RemoteFeedLoader,toCompleteWith expectedResult:RemoteFeedLoader.Result,file: StaticString = #file,line: UInt = #line,when action:() -> Void) {
    
    let exp = expectation(description: "wait for load completion")
    
    sut.load { receivedResult in
      switch (receivedResult,expectedResult) {
      case let (.success(reciverItems), .success(expectedItems)):
        XCTAssertEqual(reciverItems, expectedItems,file:file,line:line)
      case let (.failure(recieverError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
        XCTAssertEqual(recieverError,expectedError,file:file,line:line)
        
      default: XCTFail("Expected result \(expectedResult) got \(receivedResult) insted",file: file,line: line)
      }
      exp.fulfill()
    }
      action()
    
    wait(for: [exp], timeout: 1.0)
  }
  
  //MARK: Helpers
 
  private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
     // By using factory methods in our test scope , we also prevent our test methods from breaking in the future if we ever decide to change the production type again!
    return .failure(error)
  }

  private func makeSUT(url: URL =  URL(string: "http://a-given-url.com")!,file: StaticString = #file, line: UInt = #line) -> (HTTPClientSpy, RemoteFeedLoader) {
      let client = HTTPClientSpy()
      let sut = RemoteFeedLoader(url: url,client: client)
      
    trackMemoryLeaks(sut)
    trackMemoryLeaks(client)
    
    return (client,sut)
    
  }
  
  private func trackMemoryLeaks (_ instance: AnyObject,file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance,"instance should have been deallocated.Potential memory leak.",file: file,line: line)
      
    }
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
  
  func complete(withStatusCode code:Int,data:Data, at index:Int = 0) {
    let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
    messeges[index].completion(.success(data,response))
  }
  



}

