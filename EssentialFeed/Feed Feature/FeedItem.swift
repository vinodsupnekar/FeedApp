//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 07/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
