//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 19/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
  case success(Data,HTTPURLResponse)
  case failure(Error)
}
public protocol HTTPClient {
//  static var shared = HTTPClient()
  func get(from url: URL,completion	: @escaping ((HTTPClientResult) -> Void))
}

public final class RemoteFeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public enum Result: Equatable {
    case success([FeedItem])
    case failure(Error)
  }
  
  public init(url: URL,client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
  public func load(completion:  @escaping (Result) -> Void) {
    client.get(from: url){
      response in
      switch response{
        case .success(let httpResponse):
          print(httpResponse)
          completion( .failure(.invalidData))
        case .failure:
          completion( .failure(.connectivity))
      }
       
    }
}
}
