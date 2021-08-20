//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by vinod supnekar on 20/08/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import XCTest

final class FeedViewController {
    init( loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    //MARK:- Helpers
    
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }

}
