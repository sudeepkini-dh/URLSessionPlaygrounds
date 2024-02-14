//: [Previous](@previous)

import UIKit
import Foundation

class RestAPIExampleCustomUrlProtocol: URLProtocol {

  static var isReplaying = false

  override class func canInit(with task: URLSessionTask) -> Bool {
    print(" \n\n------ Inside canInit for `URLSessionTask` -----")
    if let request = task.originalRequest {
      print("\n\n Original request")
      print("Task URL : \((String(describing:request.url)))")
      print("Task Http Method : \((String(describing:request.httpMethod)))")
      print("Task Http Body : \((String(describing: request.httpBody?.prettyPrintedJSONString)))")
    } else {
      print("No Original request - probably a redirect ? ")
    }

    if isReplaying == true {
      return true
    }

    print("Reponse \(task.response)")
    return false
  }

  override class func canInit(with request: URLRequest) -> Bool {

    print(" \n\n------ Inside canInit for `URLRequest` ----- ")
    print("Task URL : \((String(describing:request.url)))")
    print("Task Http Method : \((String(describing:request.httpMethod)))")
    print("Task Http Body : \((String(describing: request.httpBody?.prettyPrintedJSONString)))")
    if isReplaying == true {
      return true
    }
    return false
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    print("url session request in canonicalRequest : \(String(describing: request.url)) \n \(String(describing: request.httpMethod)) \n \( String(describing:request.httpBodyStream))")
    return request
  }

  override func startLoading() {

  }

  override func stopLoading() {

  }

}

class CustomUrlProtocol2: URLProtocol {

}
// registers protocol class for `URLSession.shared`
URLProtocol.registerClass(RestAPIExampleCustomUrlProtocol.self)
let urlsessionCongif = URLSessionConfiguration.default
// register custom URL protocol at Session level
// regsiters protocol classes for session generated using custom configuration
urlsessionCongif.protocolClasses = [RestAPIExampleCustomUrlProtocol.self]
//Register session at global level - we have to test this

//URLProtocol.registerClass(CustomUrlProtocol2)

let urlSession = URLSession(configuration: urlsessionCongif)

// configure a session delegate

// Get Request

guard let geturl = URL(string: "https://dummy.restapiexample.com/api/v1/employees") else {
  exit(0)
}

let geturlRequest = URLRequest(url: geturl)

let reponseHandler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in

  print("\n\n  ---- Inside Response Handler --- \n\n ")
  print("Data: \(data?.prettyPrintedJSONString ?? "No data")")
  print("URL reponse \(String(describing:response))")
  print("Error \(String(describing:error))")

}
let datatask = urlSession.dataTask(with: geturlRequest,completionHandler: reponseHandler)

print("about to start get request \(datatask)")
datatask.resume()

//var urlComponents = URLComponents(string: "https://dummy.restapiexample.com/api/v1/employees")
//
//urlComponents.
//let datatask = urlSession.dat

// do a get, post , put and delete request + url session download task


// post request
guard let postRequestUrl = URL(string: "https://dummy.restapiexample.com/api/v1/create") else {
  exit(0)
}

struct EmployeeDetails: Encodable {

  let name: String
  let salary: Int
  let age: Int

}
print("")
var postRequest = URLRequest(url: postRequestUrl)
postRequest.httpMethod = "POST"

let newEmployee = EmployeeDetails(name: "john doe", salary: 123, age: 44)
postRequest.httpBody = JSONEncoder().encode(newEmployee)
let postDatatask = urlSession.dataTask(with: postRequest,completionHandler: reponseHandler)
//URLProtocol.registerClass(CustomUrlProtocol.self)
postDatatask.resume()







class RecorderSession: URLSession {




}



class testSelectionDelegate: URLSessionDelegate {

}

//: [Next](@next)
