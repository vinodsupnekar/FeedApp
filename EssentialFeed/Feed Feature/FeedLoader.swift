//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by vinod supnekar on 07/05/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public typealias LoadFeeedResult = Result<[FeedImage],Error>

// Using "Error" type here need to consider:-
/*1.Staring from abstractions bear risk. For Example, over abstracting
to accomodat future needs(that will never happen) can unnecessarily damage/complicate the current design.
 
 2. In the error case,we don't know and don't need to know yet all errors this feature will have to handle.
 Choosing error types at this time might be trying to make too many upfront decisions.
 
 3.Good design is rarely achieved in the first iteration.Software Design is an evolutionary process.Folllow good design principles and practices ,so you can easily//safely/quickly change your mind later.
 */

 public protocol FeedLoader {
//  associatedtype Error: Swift.Error
  
  func load(completion: @escaping (LoadFeeedResult) -> Void)
}
