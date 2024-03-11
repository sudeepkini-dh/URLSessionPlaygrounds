///: [Previous](@previous)

import Foundation

// Uitility
struct ReponseData: Encodable {
  let messsage: String
}

let testresponse = ReponseData(messsage: "hello - world")
let testResponseData = JSONEncoder().encode(testresponse)

typealias URLTaskCompletion = (Data?,URLResponse?,Error?) -> Void

//: [Next](@next)


// As demonstrated below you cannot subclass URLSession as
// the initalizers that we commonly use are "dummy" ones and
// cannot be called from sub class.
// At compile time you will get following error:
// error: must call a designated initializer of the superclass 'URLSession'
// super.init(configuration: configuration)
// ^
// Foundation.URLSession:6:30: note: convenience initializer is declared here
// public /*not inherited*/ init(configuration:  URLSessionConfiguration)
// ^

// source: https://stackoverflow.com/questions/32950213/initializer-does-not-override-a-designated-initializer-while-subclassing-nsurlse.

class testSubclass: URLSession {
  //  init(configuration: URLSessionConfiguration) {
  //    super.init(configuration: configuration)
  //  }
  //futher you can't override aync await functions as they aren't open
  override func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    return await try super.data(for: request)
  }
}

let session = testSubclass(configuration: URLSessionConfiguration.default)

runGetRequestUsingTask(with: session, and: nil)



