//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 19/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation


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
    client.get(from: url){ [weak self] response in
      guard self != nil else { return }

      switch response{
      case let .success(data, response):
              return completion(FeedItemsMapper.map(data, from: response))            
        case .failure:
          completion( .failure(.connectivity))
        break
      }
       
    }
 }
  

  
}




