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
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeeedResult
    private let calender = Calendar(identifier: .gregorian)

    public init(store: FeedStore, currentDate: @escaping ()  -> Date ) {
        self.store = store
        self.currentDate = currentDate
        let cls = TestUnownedVariables()
//        cls.testCode()
//        cls.testUnownedRef()
        cls.testUnOwnedRefWithImplicitlyUnwrappedOptional()
    }

    public func load(completion: @escaping (LoadResult?) -> Void) {
        store.retrieve { [unowned self] result  in
            switch result {
                case let .failure(error) :
                    completion(.failure(error))
                case let .found(feed,timestamp) where   self.validate(timestamp):
                completion(.success(feed.toModel()))
                case  .found,.empty:
                    completion(.success([]))
            }
        }
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        
        return currentDate() < maxCacheAge
    }
    
    public func save(_ feed:[FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)

            }
            else {
                self.cache(feed,with:completion)
                
            }
        }
    }   
    
    private func cache(_ feed:[FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate(), completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
    }
}

private class Department {
    var name: String
    var courses: [Course]
    init(name: String) {
        self.name = name
        self.courses = []
    }
    deinit { print("Department #\(self.name) is being deinitialized") }
}

private class Course {
    var name: String
    unowned var department: Department
    unowned var nextCourse: Course?
    init(name: String, in department: Department) {
        self.name = name
        self.department = department
        self.nextCourse = nil
    }
    deinit { print("Course #\(self.name) is being deinitialized") }
}

private class TestUnownedVariables {
    
    func testCode() {
        var department: Department? = Department(name: "Horticulture")
        let intro = Course(name: "Survey of Plants", in: department!)
        let intermediate = Course(name: "Growing Common Herbs", in: department!)
        let advanced = Course(name: "Caring for Tropical Plants", in: department!)
        print("intro next course is \(intro.nextCourse)")
            intro.nextCourse = intermediate
            intermediate.nextCourse = advanced
        department!.courses = [intro, intermediate, advanced]
        
//        department.courses = []
        department = nil
    }
    
    func testUnownedRef() {
        var john: Customer? = Customer(name: "John Appleseed")
        john!.card = CreditCard(number: 1234_5678_9012_3456, customer: john!)
    
        john = nil
    }
    
    func testUnOwnedRefWithImplicitlyUnwrappedOptional() {
            let country = Country(name: "Canada", capitalName: "Ottawa")
            print("\(country.name)'s capital city is called \(country.capitalCity.name)")
    }
    
}

class Customer {
    var name: String
    var card: CreditCard?
    init(name: String) {
        self.name = name
    }
    deinit { print("\(name) is being deinitialized") }
}

class CreditCard {
    let number: UInt64
    unowned let customer: Customer
    init(number: UInt64, customer: Customer) {
        self.number = number
        self.customer = customer
    }
    deinit { print("Card #\(number) is being deinitialized") }
}


class Country {
    let name: String
    var capitalCity: City!
    init(name: String, capitalName: String) {
        self.name = name
        self.capitalCity = City(name: capitalName, country: self)
    }
}

class City {
    let name: String
    unowned let country: Country
    init(name: String, country: Country) {
        self.name = name
        self.country = country
    }
    
}
