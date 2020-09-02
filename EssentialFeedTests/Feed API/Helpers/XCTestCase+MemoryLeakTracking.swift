//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by PlayerzPotMedia on 02/09/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import XCTest

extension XCTestCase {
  
   func trackMemoryLeaks (_ instance: AnyObject,file: StaticString = #file, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
    XCTAssertNil(instance,"instance should have been deallocated.Potential memory leak.",file: file,line: line)
    }
  }
  
}
