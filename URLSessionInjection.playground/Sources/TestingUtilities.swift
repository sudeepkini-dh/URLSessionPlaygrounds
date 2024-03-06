import Foundation
import _Concurrency


// Testing API :
let baseURL = "http://dummy.restapiexample.com/api/v1"
let employeeId = "1234"
let getURL =  URL(string: "\(baseURL)/employees")!
let postURL = URL(string: "\(baseURL)/create")!
let putURL = URL(string: "\(baseURL)/update/\(employeeId)")!
let deleteURL = URL(string: "\(baseURL)/delete/\(employeeId)")!


// Data POJO
public struct EmployeeDetails: Encodable {
  let name: String
  let salary: Int
  let age: Int
}


// Utility

// TODO : Sudeep Kini, adding testing for Upload and Download tasks

// Compltion handler method
func generateResponseHandler(for request: URLRequest) -> URLTaskCompletion {
  return { (data: Data?, response: URLResponse?, error: Error?) -> Void in

    print("\n\n  ---- Inside Response Handler --- \n\n ")
    print("Request:")
    request.prettyPrint()
    print("Data: \(data?.prettyPrintedJSONString ?? "No data")")
    print("URL reponse \(String(describing:response))")
    print("Error \(String(describing:error))")

  }
}

public func runGetRequestUsingTask(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  let getURLRequest = URLRequest(url: getURL)
  let responseHandler = generateResponseHandler(for: getURLRequest)
  let datatask = session.dataTask(
    with: getURLRequest,
    completionHandler: responseHandler)
  datatask.delegate = delegate
  print("about to start get request \(datatask)")
  datatask.resume()
}

public func runPostRequestUsingTask(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  var postRequest = URLRequest(url: postURL)
  postRequest.httpMethod = "POST"
  let newEmployee = EmployeeDetails(name: "john doe", salary: 123, age: 44)
  postRequest.httpBody = try? JSONEncoder().encode(newEmployee)
  let responseHandle = generateResponseHandler(for: postRequest)
  let postDatatask = session.dataTask(with: postRequest,completionHandler: responseHandle)
  postDatatask.delegate = delegate
  print("about to start post request \(postDatatask)")
  postDatatask.resume()
}

public func runPutRequestUsingTask(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  var putURLRequest = URLRequest(url: putURL)
  putURLRequest.httpMethod = "PUT"
  let newEmployee = EmployeeDetails(name: "john doe new", salary: 1234, age: 50)
  putURLRequest.httpBody = try? JSONEncoder().encode(newEmployee)
  let responseHandler = generateResponseHandler(for: putURLRequest)
  let datatask = session.dataTask(
    with: putURLRequest,
    completionHandler: responseHandler)
  print("about to start put request \(datatask)")
  datatask.resume()
}

public func runDeleteRequestUsingTask(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  var deleteURLRequest = URLRequest(url: deleteURL)
  deleteURLRequest.httpMethod = "DELETE"
  let responseHandler = generateResponseHandler(for: deleteURLRequest)
  let datatask = session.dataTask(
    with: deleteURLRequest,
    completionHandler: responseHandler)
  datatask.delegate = delegate
  print("about to start Delete request \(datatask)")
  datatask.resume()
}


// Aync-await method

public func print(request: URLRequest, returned:(data: Data?, response: URLResponse?)?, error: Error?) {
  print("\n\n  ---- Async Await response --- \n\n ")
  print("Request:")
  request.prettyPrint()
  print("Data: \(returned?.data?.prettyPrintedJSONString ?? "No data")")
  print("URL reponse \(String(describing: returned?.response))")
  print("Error \(String(describing:error))")
}

public func runDataTaskAsync(for request: URLRequest, on session: URLSession, with delegate: URLSessionTaskDelegate?) async {
  do {
    let (data,reponse) = try await session.data(for: request, delegate: delegate)
    print(
      request: request,
      returned: (data,reponse),
      error: nil
    )
  } catch let error {
    print(
      request: request,
      returned: nil,
      error: error
    )
  }
}

public func runGetRequestUsingAyncAwait(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  Task {
    let getURLRequest = URLRequest(url: getURL)
    await runDataTaskAsync(for: getURLRequest, on: session, with: delegate)
  }
}

public func runPostRequestUsingAyncAwait(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  Task {
    var postRequest = URLRequest(url: postURL)
    postRequest.httpMethod = "POST"
    let newEmployee = EmployeeDetails(name: "john doe", salary: 123, age: 44)
    postRequest.httpBody = try? JSONEncoder().encode(newEmployee)
    await runDataTaskAsync(for: postRequest, on: session, with: delegate)
  }
}

public func runPutRequestUsingAyncAwait(with session: URLSession, and delegate: URLSessionTaskDelegate?)  {
  Task {
    var putURLRequest = URLRequest(url: putURL)
    putURLRequest.httpMethod = "PUT"
    let newEmployee = EmployeeDetails(name: "john doe new", salary: 1234, age: 50)
    putURLRequest.httpBody = try? JSONEncoder().encode(newEmployee)
    await runDataTaskAsync(for: putURLRequest, on: session, with: delegate)
  }
}

public func runDeleteRequestUisngAyncAwait(with session: URLSession, and delegate: URLSessionTaskDelegate?) {
  Task {
    var deleteURLRequest = URLRequest(url: deleteURL)
    deleteURLRequest.httpMethod = "DELETE"
    await runDataTaskAsync(for: deleteURLRequest, on: session, with: delegate)
  }
}
