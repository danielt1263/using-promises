/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Promise

let apiKey = "da86792bb517cd3b603f4f62de8c3af2"

class Flickr {
  
  let processingQueue = OperationQueue()
  
  func searchFlickrForTerm(_ searchTerm: String, completion : @escaping (_ results: FlickrSearchResults?, _ error : Error?) -> Void){
    
    guard let searchURL = flickrSearchURLForSearchTerm(searchTerm) else {
      let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
      completion(nil, APIError)
      return
    }
    
    let searchRequest = URLRequest(url: searchURL)
    
    let data = URLSession.shared.data(with: searchRequest)
    let resultsDictionary = data.then { try typeOrThrow(try JSONSerialization.jsonObject(with: $0, options: []), isType: [String: Any].self) }
      .then { resultsDictionary -> [String: Any] in
        let stat = try typeOrThrow(resultsDictionary["stat"], isType: String.self)
        switch stat {
        case "ok":
          print("Results processed OK")
          
        case "fail":
          let message = resultsDictionary["message"] ?? "Unknown API response"
            throw NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: message])
          
        default:
          throw NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "Unknown API response"])
        }
        return resultsDictionary
    }

    let photosContainer = resultsDictionary.then { try typeOrThrow($0["photos"], isType: [String: Any].self) }
    let photosReceived = photosContainer.then { try typeOrThrow($0["photo"], isType: [[String: Any]].self) }
    
    photosReceived.then { photosReceived in
      var flickrPhotos = [FlickrPhoto]()
      
      for photoObject in photosReceived {
        if let flickrPhoto = FlickrPhoto(json: photoObject) {
          flickrPhotos.append(flickrPhoto)
        }
      }
      
      OperationQueue.main.addOperation({
        completion(FlickrSearchResults(searchTerm: searchTerm, searchResults: flickrPhotos), nil)
      })
      
    }
    .catch { error in
      OperationQueue.main.addOperation({
        completion(nil, error)
      })
    }
  }
  
  fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String) -> URL? {
    
    guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
      return nil
    }
    
    let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=20&format=json&nojsoncallback=1"
    
    guard let url = URL(string:URLString) else {
      return nil
    }
    
    return url
  }
}

func typeOrThrow<T>(_ obj: Any?, isType: T.Type) throws -> T {
  guard let result = obj as? T else { throw BadType(obj: obj, type: T.self) }
  return result
}

struct BadType: Error {
  init<T>(obj: Any?, type: T.Type) {
    localizedDescription = "object \(String(describing: obj)) was not of type \(T.self)"
  }
  
  let localizedDescription: String
}
