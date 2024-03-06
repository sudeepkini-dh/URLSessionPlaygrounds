// Playground generated with 🏟 Arena (https://github.com/finestructure/arena)
// ℹ️ If running the playground fails with an error "No such module"
//    go to Product -> Build to re-trigger building the SPM package.
// ℹ️ Please restart Xcode if autocomplete is not working.

import Embassy
import Foundation

var urlSessionConfig = URLSessionConfiguration.default
let urlSession = URLSession(configuration: urlSessionConfig)
let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let succulent = Succulent(recordTo: docDirectory, baseUrl: URL(string: "https://dummy.restapiexample.com/")!)
succulent.start()

print("Document directory: \(docDirectory)")

// post request
guard let postRequestUrl = URL(string: "https://dummy.restapiexample.com/api/v1/create") else {
  exit(0)
}

struct EmployeeDetails: Encodable {

  let name: String
  let salary: Int
  let age: Int

}

let reponseHandler = { (data: Data?, response: URLResponse?, error: Error?) -> Void in

  print("\n\n  ---- Inside Response Handler --- \n\n ")
  print("Data: \(data?.prettyPrintedJSONString ?? "No data")")
  print("URL reponse \(String(describing:response))")
  print("Error \(String(describing:error))")

}


var postRequest = URLRequest(url: postRequestUrl)
postRequest.httpMethod = "POST"

let newEmployee = EmployeeDetails(name: "john doe", salary: 123, age: 44)
postRequest.httpBody = JSONEncoder().encode(newEmployee)
let postDatatask = urlSession.dataTask(with: postRequest,completionHandler: reponseHandler)
//URLProtocol.registerClass(CustomUrlProtocol.self)
postDatatask.resume()





