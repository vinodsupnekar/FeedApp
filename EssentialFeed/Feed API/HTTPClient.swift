//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 01/07/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
  case success(Data,HTTPURLResponse)
  case failure(Error)
}

public protocol HTTPClient {
//  static var shared = HTTPClient()
  func get(from url: URL,completion: @escaping ((HTTPClientResult) -> Void))
}

