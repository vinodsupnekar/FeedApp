//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 01/11/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping ()  -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items:[FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)

            }
            else {
                self.cache(items,with:completion)
                
            }
        }
    }
    
    private func cache(_ items:[FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCacheFeed(completion : @escaping DeletionCompletion)
    func insert(_ items: [FeedItem],timestamp: Date,completion : @escaping InsertionCompletion)
    
}
