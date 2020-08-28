//
//  URLSessionHttpClientTests.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 27/08/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest

class URLSessionHttpClient {
    private let session : URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url:URL) {
        self.session.dataTask(with: url) { (_, _, _) in
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
        urlSessionClient.get(from: url)
        
        //Expectation
        XCTAssertEqual(dataTask.resumeCallCount, 1)
    }

  class URLSessionSpy :URLSession {
    private var stubs = [URL: URLSessionDataTask]()
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return stubs[url]!
        
    }
    
    func stub(url: URL, dataTask: URLSessionDataTask) {
        stubs[url] = dataTask
    }
    
    private class FakeURLSessionDataTask :URLSessionDataTask {
        
    }
    
     class URLSessionDataTaskSpy :URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
 }
}
