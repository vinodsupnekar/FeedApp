//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 19/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public protocol HTTPClient {
//  static var shared = HTTPClient()
  func get(from url: URL)
}


public final class RemoteFeedLoader {
  let url: URL
  let client: HTTPClient
  
  public init(url: URL,client: HTTPClient) {
    self.client = client
    self.url = url
  }
  public func load() {
    client.get(from: url)
  }
}
