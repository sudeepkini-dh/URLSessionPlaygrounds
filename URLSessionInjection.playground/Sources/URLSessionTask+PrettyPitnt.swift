import Foundation

public extension URLSessionTask {
  func prettyPrint() {
    print("task ID : \(self.taskIdentifier)")
    if let request = self.originalRequest {
      print("\n\n Original request")
      request.prettyPrint()
    } else {
      print("No Original request - probably a conversion from another task ")
    }
    print("current state: \(self.state)")
    if let reponse = self.response {
      print("\(reponse)")
    }
  }
}

public extension URLRequest {
  func prettyPrint() {
    print("Task URL : \((String(describing: self.url)))")
    print("Task Http Method : \((String(describing: self.httpMethod)))")
    print("Request Headers: \(String(describing: self.allHTTPHeaderFields))")
    if let body = self.httpBody {
      print("Task Http Body: \n\(String(describing: body.prettyPrintedJSONString))")
    }
  }
}


