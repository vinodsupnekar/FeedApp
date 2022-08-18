//
//  FeedImageViewModel+PrototypeData.swift
//  Prototype
//
//  Created by vinods.alt on 18/08/22.
//

import Foundation

extension FeedImageViewModel {
    static var prototypeFeed: [FeedImageViewModel] {
        return [ FeedImageViewModel(description: "ssdsd sdsds  ssdsd sdsds ssdsd sdsds ssdsd sdsds ", location: "Pune", imageName: "image-1"),
                 FeedImageViewModel(description: "ssdsd sdsds  ssdsd sdsds ssdsd sdsds ssdsd sdsds ssdsd sdsds  ssdsd sdsds ssdsd sdsds ssdsd sdsdsssdsd sdsds  ssdsd sdsds ssdsd sdsds ssdsd sdsds ", location: "Sanglu", imageName: "image-2"),
                 FeedImageViewModel(description: nil, location: "Satara", imageName: "image-3")]
    }
}
