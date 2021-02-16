//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 11/02/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import Foundation

// extension NSPersistentContainer {
//    enum LoadingError: Swift.Error {
//        case modelNotFound
//        case failedToLoadPersistentStores(Swift.Error)
//    }
//
//    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
//
//        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
//            throw LoadingError.modelNotFound
//        }
//
//        let description = NSPersistentStoreDescription(url: url)
//        let contatiner = NSPersistentContainer(name: name, managedObjectModel: model)
//        contatiner.persistentStoreDescriptions = [description]
//
//        var loadError: Swift.Error?
//        contatiner.loadPersistentStores {
//            loadError = $1
//        }
//
//        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
//
//        return contatiner
//    }
//}
//
//private extension NSManagedObjectModel {
//    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
//        return bundle.url(forResource: name, withExtension: "momd").flatMap {
//            NSManagedObjectModel(contentsOf: $0)
//        }
//    }
//}
