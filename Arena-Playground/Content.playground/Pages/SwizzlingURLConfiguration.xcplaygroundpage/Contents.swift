//: [Previous](@previous)

import Foundation


// This approch builds on `URLP`
class myDowbloadTask: URLSessionDataTask {
  override func resume() {
    print("this is my downalod task")
    super.resume()
  }
}

class proxyDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {

    print("didReceive data")
    if let request = dataTask.originalRequest {
      print("\n\n Original request")
      print("Task URL : \((String(describing:request.url)))")
      print("Task Http Method : \((String(describing:request.httpMethod)))")
      print("Task Http Body : \((String(describing: request.httpBody?.prettyPrintedJSONString)))")
    } else {
      print("No Original request - probably a redirect ? ")
    }

    if let response = dataTask.response {
      print("\n\n URL Response")
      print(String(describing: response))
    }
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    print("didReceive response")
    if let request = dataTask.originalRequest {
      print("\n\n Original request")
      print("Task URL : \((String(describing:request.url)))")
      print("Task Http Method : \((String(describing:request.httpMethod)))")
      print("Task Http Body : \((String(describing: request.httpBody?.prettyPrintedJSONString)))")
    } else {
      print("No Original request - probably a redirect ? ")
    }

    if let response = dataTask.response {
      print("\n\n URL Response")
      print(String(describing: response))
    }
    completionHandler(.allow)
  }
}



extension URLSession {

  @objc func _recorableDataTask(with request: URLRequest) -> URLSessionDataTask {
    print("In the Injected method")
    let testCompltionHandler: ((Data?, URLResponse?, Error?) -> ()) = { (data,response,error) in
      print("proxy")
    }
    return dataTask(with: request, completionHandler: testCompltionHandler)
    //_recorableDataTask(with: request)
  }

  @objc func _recorableData(for request: URLRequest) async throws -> (Data, URLResponse) {
    let (data,responce) = try await data(for: request)
    print("from inside the proxy")
    print(String(describing:responce))
    return (data,responce)
  }

}

extension URLSession {
  static func injectNetworkLayer() {
    let originalSelector = #selector((URLSession.dataTask(with:)) as (URLSession) -> (URLRequest) -> URLSessionDataTask)
    let swizzledSelector = #selector(URLSession._recorableDataTask(with:))

    guard let originalMethod = class_getInstanceMethod(self, originalSelector),
          let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
      return
    }
    method_exchangeImplementations(originalMethod, swizzledMethod)


    //cannot swizzle swift aync await methods
    //    let originalSelector2 = #selector(URLSession.data(for:))
    //    let swizzledSelector2 = #selector(URLSession._recorableData(for:))
    //
    //    guard let originalMethod2 = class_getInstanceMethod(self, originalSelector2),
    //          let swizzledMethod2 = class_getInstanceMethod(self, swizzledSelector2) else {
    //      return
    //    }
    //    method_exchangeImplementations(originalMethod2, swizzledMethod2)
  }
}

URLSession.injectNetworkLayer()
let proxy = proxyDelegate()

let urlsession = URLSession(configuration: URLSessionConfiguration.default,
                            delegate: proxy,
                            delegateQueue: nil
)

let urlRequest = URLRequest(url: URL(string: "https://dummy.restapiexample.com/api/v1/employees")!)

let task = urlsession.dataTask(with: urlRequest)

task.resume()

Task {
  let (data,response) = try await urlsession.data(for: urlRequest)
  print(" in the result \(response)")
}


//: [Next](@next)
