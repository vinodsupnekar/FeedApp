//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 07/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 1)
}

func anyURL() -> URL {
  return URL(string: "www.any-url.com")!
}
