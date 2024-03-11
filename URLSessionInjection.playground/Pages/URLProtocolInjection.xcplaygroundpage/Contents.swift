import UIKit

//: [Previous](@previous)

import Foundation

// 'URLProtocol' subclass for intersecption of URLRequests

// Uitility
struct ReponseData: Encodable {
  let messsage: String
}

let testresponse = ReponseData(messsage: "hello - world")
let testResponseData = JSONEncoder().encode(testresponse)
//testResponseData.forEach { print(String(format: "%02x", $0)) }

class TestProtocol: URLProtocol {
  static var intercept = true
  override class func canInit(with request: URLRequest) -> Bool {
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    // notice that request body isn't available here
    // this is becase as soon as you task is "resumed" httpbody get converted into a data
    // stream object on the URLSessionTask. Probably why we have "originaltask" property on URLSessionTask which is a copy.
    request.prettyPrint()
    return intercept
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    // notice that this function is only called if canInit returns true
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    request.prettyPrint()
    //can possibly modify request here
    return request
  }

  override func startLoading() {
    guard let url = request.url else { return }
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    // notice if you try to get data from request object here body will be missing
    // instead we have to use 'originalRequest' param on task Object.
    request.prettyPrint()
    // why is task optionl here?
    task?.originalRequest?.prettyPrint()

    let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: "HTTP/1.1",
      headerFields: ["test":"testvalue"]
    )
    guard let response = response else { return }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    // this will be passed to completion handler for the Data task and Task delegate as 'data' value
    client?.urlProtocol(self, didLoad: testResponseData)
    // notice you can keep calling didload data till 'urlProtocolDidFinishLoading' is called
    //    let testDataSplit =  testResponseData.split(separator: 0x6d)
    //    testDataSplit.forEach { data in
    //      client?.urlProtocol(self, didLoad: data)
    //    }
    //this call will tell client that loading is complete and will lead to calling "stoploading()"
    // if you don't call this function before session timeout it will cause url request ot fail
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===\n\n")
  }

  override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
    // we can try catpure the request here
    super.init(request: request, cachedResponse: cachedResponse, client: client)
  }
}


let config = URLSessionConfiguration.default

config.protocolClasses = [TestProtocol.self]
let session = URLSession(configuration: config)
runPutRequestUsingTask(with: session, and: nil)


class TestProtocolUsingTask: TestProtocol {

  override class func canInit(with task: URLSessionTask) -> Bool {
    //notice that if this function is defined then with `canInit(with: URLRequest)` isn't called
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    task.prettyPrint()
    return intercept
  }

}

//let config2 = URLSessionConfiguration.default
//
//config2.protocolClasses = [TestProtocolUsingTask.self]
//let session2 = URLSession(configuration: config2)
//runPutRequestUsingTask(with: session2, and: nil)

class NetworkObserverProtocol: URLProtocol {

  static var intercept = true

  // Since we are using our own internal session and creating
  // our own shadow tasks, we will need to forward `delegate`
  // calls to original task 'delegate'. This can be done
  // partially using the `client` property (set by URLProtocol)
  // or by using delegate property on the original task.

  // check `URLProtocolClient` documentation for available
  // functions. or check implementation below.

  // Also Notice that there is no way to get instance of the
  // original URLSession. Hence its delegate so we will loose
  // any buisness logic that is implemented with using session
  // delegate eg: responsding to auth challenges, storing cookies etc.
  static let session = URLSession(configuration: .ephemeral)

  // must be implemented else it will cause a crash
  override class func canInit(with request: URLRequest) -> Bool {
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    request.prettyPrint()
    return intercept
  }

  override class func canInit(with task: URLSessionTask) -> Bool {
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    task.prettyPrint()
    return intercept
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    // notice that this function is only called if canInit returns true
    // notice headers set via Session configurations are available here
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    request.prettyPrint()
    //can possibly modify request here
    return request
  }

  override func startLoading() {
    print("\n\n ==== Inside class: \(String(describing: self)) function: \(#function) ===")
    // notice if you try to get data from request object here, body will be missing
    // instead we have to use 'originalRequest' param on task Object.
    // here `request` object had Configuration level headers but `task.originalRequest` does not.
    request.prettyPrint()
    print("\nThe original request\n")
    // why is task optional here?
    task?.originalRequest?.prettyPrint()
    guard let client = self.client else { return }

    Task.detached { [self] in

      do {
        // notice here that we are using our own data task to get the actual response
        // Also note that this can cause an infinite loop if this procotol is appied
        // to Default session or to all sessions using swizzling.
        // solution: https://github.com/apple/swift-corelibs-foundation/issues/4324
        let (data, response) = try await Self.session.data(for: request)
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        client.urlProtocol(self, didLoad: data)
        client.urlProtocolDidFinishLoading(self)
      } catch {
        client.urlProtocol(self, didFailWithError: error)
      }
    }
  }

  override func stopLoading() {
    print("\n\n ==== Inside class: \(String(describing: self)q) function: \(#function) ===")
  }
}


//let config3 = URLSessionConfiguration.default
//
//config3.protocolClasses = [NetworkObserverProtocol.self]
//let session3 = URLSession(configuration: config3)
//
//runPostRequestUsingTask(with: session3, and: nil)
//runPostRequestUsingAyncAwait(with: session3, and: nil)


// Using URLPotocol at global level.

class CustomUrlProtocol1: URLProtocol {}

// Registers Protocol With URLSesson.Shared
URLProtocol.registerClass(NetworkObserverProtocol.self)

//let session4 = URLSession.shared
//runPostRequestUsingTask(with: session4, and: nil)

// Notice that you will need to set URLProtocols when you create your own session
// here NetworkObserverProtocol is not checked with unless explicitly registered using session configuration.

//let config5 = URLSessionConfiguration.default
//let session5 = URLSession(configuration: config5)
//runPostRequestUsingTask(with: session5, and: nil)

// Notice that the last registered protocol is asked first for "canInit". if it
// retruns `yes` then Loading system will had over the request to an instance of that class
// and not forward it to any other protocol. If it returns `no` is will check with the next
// in line
// URLProtocol.registerClass(TestProtocol.self)

// This can be problematic as other frameworks and objects can register  their protocols after we have ours
// hence we will a way to ensure our protocol remains first in line.

// configuratioh headers test

let config6 = URLSessionConfiguration.default
config6.httpAdditionalHeaders = ["test":"hello world"]
config6.protocolClasses = [NetworkObserverProtocol.self]
let session6 = URLSession(configuration: config6)
runPostRequestUsingTask(with: session6, and: nil)


class NetworkObserverProtocolV2: NetworkObserverProtocol {

  override func startLoading() {
    guard let client = self.client else { return }
    Task.detached { [self] in
      try await Self.session.data(for: request, delegate: self)
    }
  }
}

extension NetworkObserverProtocolV2: URLSessionTaskDelegate {

}


extension NetworkObserverProtocolV2: URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    client?.urlProtocol(self, didLoad: data)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
    completionHandler(.allow)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      client?.urlProtocol(self, didFailWithError: error)
    } else {
      client?.urlProtocolDidFinishLoading(self)
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    completionHandler(request)
  }

  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    guard let error = error else { return }
    client?.urlProtocol(self, didFailWithError: error)
  }

  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    let protectionSpace = challenge.protectionSpace
    let sender = challenge.sender

    // Notice here we are using our own handling for Authentication challenge.
    // there is no way to pass this on to original session delegate. We may get
    // lucky if the `task.delegate` is the data delegate. But even then URLSession
    // object that we pass on will not be the same.


    // This may not be a problem in unit testing environment as stageing server
    // might be behind a VPN which mean you are not likely to get a challenge.

    if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      if let serverTrust = protectionSpace.serverTrust {
        let credential = URLCredential(trust: serverTrust)
        sender?.use(credential, for: challenge)
        completionHandler(.useCredential, credential)
        return
      }
    }
  }

  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    client?.urlProtocolDidFinishLoading(self)
  }
}



//: [Next](@next)

