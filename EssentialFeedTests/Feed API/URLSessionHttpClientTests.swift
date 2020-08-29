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
    
    init(session: URLSession) {
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
    
    func test_getFromURL_resumeDataTaskWithURL() {
        //Set-up
        let url = URL(string:"www.any-url.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionSpy.URLSessionDataTaskSpy()
        
        session.stub(url: url,dataTask: dataTask)
        
        let urlSessionClient = URLSessionHttpClient(session: session)
        urlSessionClient.get(from: url, completion: { _ in  })
        
        //Expectation
        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        //Set-up
        let url = URL(string:"www.any-url.com")!
        let error = NSError(domain: "my error", code: 1)

        let session = URLSessionSpy()
        session.stub(url: url,error: error)
        
        let exp = expectation(description: "wait for completion")
        let urlSessionClient = URLSessionHttpClient(session: session)
        urlSessionClient.get(from: url, completion: { result in
            switch result {
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError, error)
            default:
                XCTFail("Expected failure with error \(error),got result \(result) instead")
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        //Expectation
//        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }

  class URLSessionSpy :URLSession {
    private var stubs = [URL: Stub]()
    
    private struct Stub {
        let task: URLSessionDataTask
        let error: Error?
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        guard let stub = stubs[url] else {
            fatalError("Couldn't find stub for \(url)")
        }
            completionHandler(nil,nil,stub.error)
            return stub.task
    }
    
    func stub(url: URL, dataTask: URLSessionDataTask = FakeURLSessionDataTask(), error:Error? = nil) {
        stubs[url] = Stub(task: dataTask, error: error)
    }
    
    private class FakeURLSessionDataTask :URLSessionDataTask {
        override func resume() {
        }
    }
    
     class URLSessionDataTaskSpy :URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
 }
}
