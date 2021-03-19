//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 19/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  private let url: URL
  private let client: HTTPClient
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public typealias Result = FeedLoader.Result
  
  public init(url: URL,client: HTTPClient) {
    self.client = client
    self.url = url
  }
  
    public func load(completion:  @escaping (Result) -> Void) {
        client.get(from: url){ [weak self] response in
          guard self != nil else { return }
          switch response {
          case let .success((data, response)):
                completion( RemoteFeedLoader.map(data, response: response))
            case .failure:
                completion( .failure(Error.connectivity))

            break
          }
        }
    }

    private static func map(_ data:Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch  {
            return .failure(error)
        }
    }
    
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}



