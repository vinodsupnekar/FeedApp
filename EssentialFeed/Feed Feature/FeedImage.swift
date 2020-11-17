//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 07/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public struct FeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
  
  public init(id:UUID, description:String?, location:String?, url:URL) {
    self.id = id
    self.description = description
    self.location = location
    self.url = url
  }
}


