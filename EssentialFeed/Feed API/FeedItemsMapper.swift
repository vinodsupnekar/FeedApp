//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 01/07/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

internal final class FeedItemsMapper {
  
  private struct Root: Decodable {
    let items: [RemoteFeedItem]
  }
  
  private static var OK_200 : Int { return 200 }
  
  internal static func map (_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == FeedItemsMapper.OK_200,
      let root = try? JSONDecoder().decode(Root.self, from: data) else {
        throw RemoteFeedLoader.Error.invalidData
    }
    return root.items
  }
  
}
