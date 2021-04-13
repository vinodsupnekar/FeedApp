//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 02/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
 internal let id: UUID
 internal let description: String?
 internal let location: String?
 internal let image: URL
}
