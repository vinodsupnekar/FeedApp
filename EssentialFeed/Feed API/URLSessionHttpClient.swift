//
//  URLSessionHttpClient.swift
//  EssentialFeed
//
//  Created by PlayerzPotMedia on 03/09/20.
//  Copyright © 2020 VinodS. All rights reserved.
//

import Foundation

public class URLSessionHttpClient: HTTPClient {
    private let session : URLSession
    
   public init(session: URLSession = .shared) {
        self.session = session
    }
  
public struct UnexpectedValuesRepresentation: Error {
  }
    
    public func get(from url:URL,completion: @escaping (HTTPClient.Result)->Void ) {
      self.session.dataTask(with: url) { (data, response, error) in
        
        completion(Result(catching: {
            if let error = error {
                throw error
            }
            else if let data = data,let response = response as? HTTPURLResponse {
                return (data, response)
            }
            else {
                throw UnexpectedValuesRepresentation()
            }
        }))
        }.resume()
    }
}
