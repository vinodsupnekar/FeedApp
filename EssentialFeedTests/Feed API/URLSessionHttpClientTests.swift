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
    
  
    func test_getFromURL_failsOnRequestError() {
        //Set-up
        let url = URL(string:"www.any-url.com")!
        let error = NSError(domain: "my error", code: 1)
        
        URLProtocolStub.startInterceptingRequests()
//        let session = HTTPSessionSpy()
      URLProtocolStub.stub(data: nil, response: nil,error: error)
        
        let exp = expectation(description: "wait for completion")
        let urlSessionClient = URLSessionHttpClient()
        urlSessionClient.get(from: url, completion: { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError, error)
            default:
                XCTFail("Expected failure with error \(error),got result \(result) instead")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 10.0)
        URLProtocolStub.stopInterceptingRequests()
        //Expectation
//        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }

  class URLProtocolStub : URLProtocol {
    private static var stub: Stub?

    private struct Stub {
      let error: Error?
      let data: Data?
      let response: URLResponse?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub( error: error, data: data, response: response)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
    }    
    
    override class func canInit(with request: URLRequest) -> Bool {
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
