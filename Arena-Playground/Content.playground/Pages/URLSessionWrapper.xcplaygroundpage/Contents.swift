//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

//: [Next](@next)


enum NetworkReplaymode {
  case record
  case playback
  case disabled
}

protocol NetworkRecording {
  func record(request: URLRequest,
              response: URLResponse,
              data: Data?)
  func response(forRequest: URLRequest) -> (Data?,URLResponse)?
  func shouldRecordRequest(request: URLRequest) -> Bool
  var playbackDelay: Int { get }
  var mode: NetworkReplaymode { get }
}

class DummyRecorder: NetworkRecording {
  var exclusionList: [String] {
    return []
  }
  var playbackDelay: Int {
    5
  }
  var mode: NetworkReplaymode { .record }

  func record(request: URLRequest,
              response: URLResponse,
              data: Data?) {
    print("\n\n ==== Inside class: \(String(describing: DummyRecorder.self)) function: \(#function) ===")
    request.prettyPrint()
    print("\nResponse")
    print(response)
  }
  func response(forRequest: URLRequest) -> (Data?, URLResponse )? {
    guard let url = forRequest.url else {
      return nil
    }
    guard let response = HTTPURLResponse(
      url: url,
      statusCode: 200,
      httpVersion: "HTTP/1.1",
      headerFields: ["test":"testvalue"]
    ) else {
      return nil
    }
    return (testResponseData,response)
  }
  func shouldRecordRequest(request: URLRequest) -> Bool {
    return true
  }
}

protocol SessionProxy {
  func didComplete(ReplayDataTask: URLSessionDataTask)
}


class ReplayDataTask: URLSessionDataTask {

  let storedRequest: URLRequest
  let storedResponse: URLResponse
  let storedData: Data?
  var simulatedState: URLSessionTask.State

  let completionHandler: URLTaskCompletion?
  let session: URLSession
  let reponseDelay: TimeInterval

  override var originalRequest: URLRequest? {
    get {
      return storedRequest
    }
  }

  override var response: URLResponse? {
    get {
      return storedResponse
    }
  }

  override var state: URLSessionTask.State {
    get {
      return simulatedState
    }
  }

  private var workItem: DispatchWorkItem? = nil

  init(
    request: URLRequest,
    reponseDelay: TimeInterval,
    response: URLResponse,
    data: Data?,
    completionHanlder: URLTaskCompletion?,
    session: URLSession)
  {
    self.reponseDelay = reponseDelay
    self.storedRequest = request
    self.storedResponse = response
    self.storedData = data
    self.completionHandler = completionHanlder
    self.session = session
    self.simulatedState = .suspended
  }

  override func resume() {
    let delayedExecution = DispatchWorkItem { [weak self] in
      guard let self = self else {
        return
      }
      self.completionHandler?(self.storedData, self.storedResponse, nil)
      self.simulatedState = .completed
    }
    workItem = delayedExecution
    DispatchQueue.main.asyncAfter(deadline: .now() + reponseDelay, execute: delayedExecution)
  }

  override func cancel() {
    workItem?.cancel()
    self.simulatedState = .canceling
  }
}



class RecordableSession: URLSession {
  var recorder: NetworkRecording
  var responsedelay: TimeInterval = 10.0
  init(
    recorder: NetworkRecording,
    config: URLSessionConfiguration,
    delegate: URLSessionDelegate? = nil,
    delegateQueue: OperationQueue? = nil

  ) {
    super.init(configuration: config)
    self.recorder = recorder
  }

  private func internalDataTask(
    for request: URLRequest,
    completion: URLTaskCompletion?
  ) -> URLSessionDataTask {
    let task: URLSessionDataTask
    if recorder.mode == .record,
       recorder.shouldRecordRequest(request: request){
      let proxy = generateProxyHandler(
        request: request,
        original: completion
      )
      task = super.dataTask(with: request, completionHandler: proxy)
    } else if recorder.mode == .playback,
              let (data, response) = recorder.response(forRequest: request){
      task = ReplayDataTask(
        request: request,
        reponseDelay: responsedelay,
        response: response,
        data: data,
        completionHanlder: completion,
        session: self
      )
    } else {
      if let completion = completion {
        task = super.dataTask(with: request, completionHandler: completion)
      } else {
        task = super.dataTask(with: request)
      }
    }
    return task
  }

  private func internalData(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data?, URLResponse?) {

    if recorder.mode == .playback,
       let (responseData,response) = recorder.response(forRequest: request){
      try await Task.sleep(for: .seconds(recorder.playbackDelay))
      return (responseData, response)
    }
    let (responseData, response) = try await super.data(for: request)
    if recorder.mode == .record,
       recorder.shouldRecordRequest(request: request) {
      recorder.record(
        request: request,
        response: response,
        data: responseData
      )
    }
    return (responseData, response)
  }

  func generateProxyHandler(
    request: URLRequest,
    original: URLTaskCompletion?
  ) -> URLTaskCompletion {

    return { [weak self] (data,response,error)  in
      guard let self = self else {
        return
      }
      if let response = response {
        //check reponse Http status code here maybe?

        self.recorder.record(
          request: request,
          response: response,
          data: data
        )
      }
      original?(data,response,error)
    }
  }
}
// Overide functions
// Async Await


// Data task Commands

override func dataTask(
  with request: URLRequest,
  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
) -> URLSessionDataTask {
  return internalDataTask(for: request, completion: completionHandler)
}

override func dataTask(
  with url: URL,
  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
) -> URLSessionDataTask {
  let urlRequest = URLRequest(url: url)
  return internalDataTask(for: urlRequest, completion: completionHandler)
}


}


let recorder = DummyRecorder()
let config = URLSessionConfiguration.default
let session = RecordableSession(
  recorder: recorder,
  config: config)


runGetRequestUsingTask(with: session, and: nil)
