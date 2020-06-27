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
  func get(from url: URL,completion: @escaping ((HTTPClientResult) -> Void))
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
      case let .success(data, response):
        
//        do {
//          topLevel = try JSONSerialization.jsonObject(with: data)
//        } catch {
//          throw DecodingError.dataCorrupted(DecodingError.Context(
//            codingPath: [],
//            debugDescription: "The given data was not valid JSON.",
//            underlyingError: error)
//          )
//        }
        do {
          let root = try? JSONDecoder().decode(Root.self, from: data)
          if response.statusCode == 200,let rt = root {
            completion(.success(rt.items.map{
              $0.item
            }))
          }
          else {
            completion( .failure(.invalidData))

          }
          
        }
        catch {
          print(error)
          completion( .failure(.invalidData))

        }
//        if let root = try? JSONDecoder().decode(Root.self, from: data) {
//          completion(.success(root.items))
//        }
//          else {
//          completion( .failure(.invalidData))
//        }
        break
        case .failure:
          completion( .failure(.connectivity))
        break
      }
       
    }
}
}

private struct Root: Decodable {
  let items: [Item]
}

private struct Item: Decodable {
 let id: UUID
 let description: String?
 let location: String?
 let image: URL
  
  var item : FeedItem{
    return FeedItem(id: id, description: description, location: location, imageURL: image)
  }
}
