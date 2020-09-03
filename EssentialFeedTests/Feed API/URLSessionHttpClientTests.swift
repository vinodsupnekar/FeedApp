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
  
  struct UnexpectedValuesRepresentation: Error {
  }
    
    func get(from url:URL,completion: @escaping (HTTPClientResult)->Void ) {
      self.session.dataTask(with: url) { (_, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            else {
              completion(.failure(UnexpectedValuesRepresentation()))
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
    let url = anyURL()
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
      let error = NSError(domain: "my error", code: 1)
      
      let receivedError = resultErrorFor(data: nil, response: nil, error: error)

      XCTAssertEqual(receivedError as NSError? , error)
         
 }
  
     func test_getFromURL_failsOnAllNilValues() {
         //Set-up
       XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
  }

  //MARK: Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHttpClient {
    let sut = URLSessionHttpClient()
    trackMemoryLeaks(sut,file:file,line: line)
    return sut
  }
  
  private func resultErrorFor(data:Data?,response:URLResponse?,error:Error?,file:StaticString = #file,line:UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    var receivedError: Error?
    
    let sut = makeSUT(file:file,line: line)
    let exp = expectation(description: "wait for completion")
    
    sut.get(from: anyURL()) { result in
    switch result {
      case let .failure(error):
          receivedError = error
    default:
        XCTFail("Expected failure ,got result \(result) instead",file: file,line: line)
      }
    exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    return receivedError
  }
  
  private func anyURL() -> URL {
    return URL(string: "www.any-url.com")!
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
