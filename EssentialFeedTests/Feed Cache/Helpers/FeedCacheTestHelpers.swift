//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by vinod supnekar on 07/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models : [FeedImage] , local: [LocalFeedImage]) {
    let models = [uniqueImage(),uniqueImage()]
    let localItems = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    return (models,localItems)
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
