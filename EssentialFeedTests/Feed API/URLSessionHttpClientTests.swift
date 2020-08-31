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
        URLProtocolStub.stub(url: url,error: error)
        
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
    private static var stubs = [URL: Stub]()

    private struct Stub {
        let error: Error?
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocol.self)
        stubs = [:]
    }
    
    static func stub(url: URL, error:Error? = nil) {
        stubs[url] = Stub( error: error)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        return URLProtocolStub.stubs[url] != nil
    }

    override class func canonicalRequest(for request:URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url,let stub = URLProtocolStub.stubs[url]  else {
            return
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    
    override func stopLoading() { }
    

 }
}
