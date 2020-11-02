//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 02/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
  
  public init(id:UUID,description:String?,location:String?,imageURL:URL) {
    self.id = id
    self.description = description
    self.location = location
    self.imageURL = imageURL
  }
}
