//: [Previous](@previous)

import UIKit
import Foundation
import _Concurrency

// Testing out url Session Http methods and what avenues we have to record an interaction.

// Session Delegate
class TestDelegate: NSObject, URLSessionDataDelegate {
  override init() {
    print("Createing URLSessionDataDelegate")
    super.init()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void) {
    print("\n\nInside the URLSessionDataDelegate")
    print("Function: \(#function)")
    dataTask.prettyPrint()
    // default value
    completionHandler(.allow)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    print("\n\nInside the URLSessionDataDelegate")
    print("Function: \(#function)")
    dataTask.prettyPrint()
    print("Data: \(data.prettyPrintedJSONString ?? "No data")")
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    print("\n\nInside the URLSessionDataDelegate")
    print("Function: \(#function)")
    task.prettyPrint()
    if let error = error {
      print("Error:\(error.localizedDescription)")
    }
  }

}

// Creating a URLSession

let config = URLSessionConfiguration.default
let session = URLSession(configuration: config)

runGetRequestUsingTask(with: session, and: nil)






















