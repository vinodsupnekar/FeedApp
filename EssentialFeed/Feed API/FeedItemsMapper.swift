//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 01/07/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

internal class FeedItemsMapper {
  
  private struct Root: Decodable {
    let items: [Item]
    var feed: [FeedItem] {
      return items.map { $0.item }
    }
  }

  private struct Item: Decodable {
   let id: UUID
   let description: String?
   let location: String?
   let image: URL
   var item : FeedItem {
      return FeedItem(id: id, description: description, location: location, imageURL: image)
    }
  }
  
  private static var OK_200 : Int { return 200 }
  
  internal static func map(_ data :Data,_ response: HTTPURLResponse) throws -> [FeedItem] {
    guard response.statusCode == OK_200 else {
      throw RemoteFeedLoader.Error.invalidData
    }
    return try JSONDecoder().decode(Root.self, from: data).items.map {
      $0.item
    }
  }
  
  private func map (_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
    guard response.statusCode == FeedItemsMapper.OK_200,
      let root = try? JSONDecoder().decode(Root.self, from: data) else {
        return .failure(.invalidData)
    }
    let item = root.items.map { $0.item }
    return .success(item)
  }
  
}
