//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 09/12/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {
    
    private init () {}
    private static let calender = Calendar(identifier: .gregorian)
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
        return date < maxCacheAge
    }
}
