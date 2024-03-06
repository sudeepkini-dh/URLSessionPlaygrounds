//: [Previous](@previous)

import Foundation


struct Interaction {

  let identifier: String

  weak var libray: Library

  // MARK: - Properties
  
  let request: URLRequest
  let response: Foundation.URLResponse
  let responseData: Data?
  let recordedAt: Date

  init(
    request: URLRequest,
    response: Foundation.URLResponse,
    responseData: Data?,
    recordedAt: Date
  ) {
    self.identifier = identifier
    self.request = request
    self.response = response
    self.responseData = responseData
    self.recordedAt = recordedAt
  }

  // Reponsibilites
  // capture request, response, data etc in recording mode and save it to file using library
  // - this is through initilizer
  // load data from file and generate request, response, data
}

protocol NetworkRecording {

  var playbackDelay: Int?
  func interaction(forRequest: URLRequest) -> Interaction?
  init()
}


protocol URLRequestHasher {
  func generateHash(request: URLRequest) -> String
}

class urlandHttpMethordHasher: CustomURLRequestHasher {
  func generateHash(request: URLRequest) -> String {
    return request.url?.absoluteString??"" + "-" + request.httpMethod
  }
}


typealias InteractionHash = String
typealias FileName = String



protocol Library {

  // Reponsabilities
  // 1. load and save Bundle/cassette etc - load the journel a map between [Interaction Hash and File Name]
  // 2. Maintain a background queue which will be used to read data from files
  // 3. Function to save data for an interaction to a file
  // 4. Function to read data for an interaction to a file

  var journal: [InteractionHash, FileName] { get, set }
  init?(pathToLibrary: URL)
  func datafor
}

class NetworkRecorder: NetworkRecording {

  enum RecorderMode {
    case record
    case playback
  }

  enum ReorderState {
    case idle
    case active
  }

  private var state: ReorderState
  private var mode: RecorderMode
  private var hasher: URLRequestHasher

  func urlSession(
    config: URLSessionConfiguration,
    delegate: URLSessionDelegate? = nil
  ) -> ReplayableSession {
      ReplayableSession(
        recorder: self,
        config: config,
        delegate: delegate
      )
  }
  // how should we store interactions in memory?
  // we
  var recodings: []
  var playbackDelay: Int?



  var journal: [InteractionHash: FileName] // find bundle and load journal first.


  var match: ()




  init(
    libraryPath: URL,
    traceName: "String",
    overwrite: Bool,
    exclusionList: [String]
  ) {

  }

  init(
    libraryPath: URL,
    traceName: String,
    playbackDelay: Int 
  ){

  }

  func record(
    urlRequest: URLRequest,
    reponse: URLResponse,
    data: Data,
    createdat: Date = Date.now
  ) {
    guard state == .active,
          mode == .record
    else {
      return
    }
    // generate a uniqueue hash based on url request
    let hash = hasher.generateHash(request: urlRequest)



  }



    

    // check if url request is already logged
    // if logged then ignore
    return
  }

  func interaction(forRequest: URLRequest) -> Interaction? {
    guard state == .playingback else {
      return nil
    }
    // find the interaction for request and return if found
    return nil
  }
  
  func start() {
    state = .active
  }

  func stop() {
    state = .idle
    // if doing save on stop we might want to do it here, But not recomended.
  }

}




extension Session: ReplaySessionProxy {

}

protocol ReplaySessionProxy {

  func dataTaskDidComplete(
            task: ReplayDataTask,
            urlResponse: URLResponse,
            data: Data
            )
  )
}

class ReplayDataTask: URLSessionDataTask {
  var reponseDelay: Int
  var interaction: Interaction
  var compltionHanlder: URLTaskCompletion
  var dispatchqueue: DispatchQueue
  weak var session: ReplaySessionProxy
  private var workItem: DispatchWorkItem? = nil

  init(
    reponseDelay: Int,
    interaction: Interaction,
    compltionHanlder: URLTaskCompletion,
    session: ReplaySessionProxy) 
  {
    self.reponseDelay = reponseDelay
    self.interaction = interaction
    self.compltionHanlder = compltionHanlder
    self.session = session
  }

  override func resume() {
    workItem = DispatchWorkItem {
      self.compltionHanlder(
        interaction.responseData,
        interaction.response,
        nil
      )
      self.session.dataTaskDidComplete(
        task: self,
        urlResponse: interaction.response,
        data: interaction.responseData
      )
      self.state = .running
    }

    dispatchqueue.asyncAfter(
      deadline: now() + reponseDelay,
      execute: workItem
    )
  }
  
  override func cancel() {
    workItem.cancel()
    self.state = .canceling
  }

}


func swizzlemethord(
  on klass: Class,
  original: Selector,
  new: Selector
) -> Bool {
    let originialMethod = class_getInstanceMethod(klass, original)
    let swizzledMethod = class_getInstanceMethod(klass, new)
    if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
      // switch implementation..
      method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension URLSession {
  func
}
