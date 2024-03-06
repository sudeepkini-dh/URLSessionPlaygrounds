import Foundation

//class NetworkObserverProtocol: URLProtocol {
//
//  static let shadowRequestKey = "shadowRequest"
//  enum Mode {
//    case recording
//    case playingBack
//  }
//  static var state: Mode = .recording
//  static var intercept = true
//
//  static let session = URLSession(configuration: .ephemeral)
//
//  override class func canInit(with task: URLSessionTask) -> Bool {
//    guard task
//    print("\n\n ==== Inside class: \(Self.className()) function: \(#function) ===")
//    task.prettyPrint()
//
//
//    return intercept
//  }
//
//  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
//    // notice that this function is only called if canInit returns true
//    print("\n\n ==== Inside class: \(Self.className()) function: \(#function) ===")
//    request.prettyPrint()
//    //can possibly modify request here
//    return request
//  }
//
//  override func startLoading() {
//    print("\n\n ==== Inside class: \(Self.className()) function: \(#function) ===")
//    // notice if you try to get data from request object here body will be missing
//    // instead we have to use 'originalRequest' param on task Object.
//    request.prettyPrint()
//    // why is task optionla here?
//    task?.originalRequest?.prettyPrint()
//    guard let client = self.client else { return }
//
//    Task.detached { [self] in
//
//      do {
//        // notice here that we are using our own data task to get the actul response
//        // Also note that this can cause an infinite loop if this procotol is appied
//        // to Default session or to all sessions using swizzling.
//        // solution: https://github.com/apple/swift-corelibs-foundation/issues/4324
//        guard let mutableRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
//          let error = NSError(domain: "NetworkObserverProtocol", code: 100)
//          client.urlProtocol(self, didFailWithError: error)
//          return
//        }
//        URLProtocol.setProperty(true, forKey: NetworkObserverProtocol.shadowRequestKey, in: mutableRequest)
//        self.request = mutableRequest as URLRequest
//        let (data, response) = try await Self.session.data(for: mutableRequest)
//        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
//        client.urlProtocol(self, didLoad: data)
//        client.urlProtocolDidFinishLoading(self)
//      } catch {
//        client.urlProtocol(self, didFailWithError: error)
//      }
//    }
//  }
//
//  override func stopLoading() {
//    print("\n\n ==== Inside class: \(Self.className()) function: \(#function) ===")
//  }
//}
//
//
