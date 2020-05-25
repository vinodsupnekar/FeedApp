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
  func get(from url: URL,completion	: @escaping ((Error?,HTTPURLResponse?) -> Void))
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public init(url: URL,client: HTTPClient) {
    self.client = client
    self.url = url
  }
  public func load(completion:  @escaping (Error) -> Void) {
    client.get(from: url){
      error,response in
      if response != nil {
        completion(.invalidData)
      }
      else {
        completion(.connectivity)
      }
       
    }
}
}
