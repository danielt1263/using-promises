//
//  URLSession+Promise.swift
//  FlickrSearch
//
//  Created by Daniel Tartaglia on 9/3/17.
//  Copyright © 2017 Richard Turton. All rights reserved.
//

import Foundation

extension URLSession {
  public func data(with request: URLRequest) -> Promise<Data> {
    return Promise { success, failure in
      self.dataTask(with: request, completionHandler: { (data, response, error) in
        if let data = data {
          success(data)
        }
        else {
          failure(error ?? UnknownError())
        }
      }).resume()
    }
  }
}

public
struct UnknownError: Error { }
