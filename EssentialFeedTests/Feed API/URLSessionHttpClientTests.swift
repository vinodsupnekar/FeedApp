//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 27/08/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HttpSessionTask
}

protocol HttpSessionTask {
    func resume()
}

class URLSessionHttpClient {
    private let session : HTTPSession
    
    init(session: HTTPSession) {
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
        let session = HTTPSessionSpy()
        let dataTask = HTTPSessionSpy.URLSessionDataTaskSpy()
        
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

        let session = HTTPSessionSpy()
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

  class HTTPSessionSpy :HTTPSession {
    private var stubs = [URL: Stub]()
    
    private struct Stub {
        let task: HttpSessionTask
        let error: Error?
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HttpSessionTask {
        guard let stub = stubs[url] else {
            fatalError("Couldn't find stub for \(url)")
        }
            completionHandler(nil,nil,stub.error)
            return stub.task
    }
    
    func stub(url: URL, dataTask: HttpSessionTask = FakeURLSessionDataTask(), error:Error? = nil) {
        stubs[url] = Stub(task: dataTask, error: error)
    }
    
    private class FakeURLSessionDataTask :HttpSessionTask {
         func resume() {
        }
    }
    
     class URLSessionDataTaskSpy :HttpSessionTask {
        var resumeCallCount = 0
         func resume() {
            resumeCallCount += 1
        }
    }
 }
}
