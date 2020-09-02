//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 27/08/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHttpClient {
    private let session : URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url:URL,completion: @escaping (HTTPClientResult)->Void ) {
      self.session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHttpClientTests : XCTestCase {
  
  override func setUp() {
    super.setUp()
    URLProtocolStub.startInterceptingRequests()
  }
  
  override func tearDown() {
    super.tearDown()
    URLProtocolStub.stopInterceptingRequests()
  }
    
  func test_getFromURL_performsGETRequestWithURL() {
    let url = URL(string: "http://any-url.com")!
    let exp = expectation(description: "wait for requests")
    
    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    makeSUT().get(from: url) {_ in }
    wait(for: [exp], timeout: 1.0)
  }
  
    func test_getFromURL_failsOnRequestError() {
        //Set-up
      
      let url = URL(string:"www.any-url.com")!
      let error = NSError(domain: "my error", code: 1)
      //        let session = HTTPSessionSpy()
      URLProtocolStub.stub(data: nil, response: nil,error: error)
      let exp = expectation(description: "wait for completion")
      makeSUT().get(from: url) { result in
          switch result {
          case let .failure(recievedError as NSError):
              XCTAssertEqual(recievedError, error)
          default:
              XCTFail("Expected failure with error \(error),got result \(result) instead")
          }
          exp.fulfill()
      }
      wait(for: [exp], timeout: 1.0)
 }

  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
    let sut = URLSessionHttpClient()
    trackMemoryLeaks(sut,file:file,line: line)
    return sut
  }
  
  
  class URLProtocolStub : URLProtocol {
    private static var stub: Stub?
    private static var requqestObserver: ((URLRequest) -> Void)?
    private struct Stub {
      let error: Error?
      let data: Data?
      let response: URLResponse?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub( error: error, data: data, response: response)
    }
    
    static func observeRequests ( observer: @escaping (URLRequest) -> Void) {
      requqestObserver = observer
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requqestObserver = nil
    }    
    
    override class func canInit(with request: URLRequest) -> Bool {
        requqestObserver?(request)
        return true
    }

    override class func canonicalRequest(for request:URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let data = URLProtocolStub.stub?.data {
          client?.urlProtocol(self, didLoad: data)
        }
        if let response = URLProtocolStub.stub?.response {
          client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let error = URLProtocolStub.stub?.error {
          client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    
    override func stopLoading() { }
    

 }
}
