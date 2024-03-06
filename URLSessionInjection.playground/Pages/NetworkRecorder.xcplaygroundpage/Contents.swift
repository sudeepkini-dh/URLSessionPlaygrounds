//: [Previous](@previous)

import Foundation

class NetworkRecorder {
  var bundleName: String
  var exclusionList: [String]
  var matcherClosure: ((URLRequest, URLRequest) -> Bool)?
  var mode: Mode
  var journal: Journal
  var dataStorage: DataStorage

  init(bundleName: String, exclusionList: [String], matcherClosure: ((URLRequest, URLRequest) -> Bool)?, mode: Mode) {
    self.bundleName = bundleName
    self.exclusionList = exclusionList
    self.matcherClosure = matcherClosure
    self.mode = mode
    self.journal = loadJournal(from: bundleName)
    self.dataStorage = DataStorage(bundleName: bundleName)
  }

  func record(request: URLRequest, response: URLResponse?, data: Data?) {
    guard !isExcluded(request: request) else { return }
    let identifier = generateIdentifier()
    dataStorage.saveData(data, withIdentifier: identifier)
    dataStorage.saveResponse(response, withIdentifier: identifier)
    journal.addEntry(request: request, identifier: identifier)
  }

  func replay(request: URLRequest) -> String? {
    guard mode == .replay else { return nil }
    return journal.findMatchingIdentifier(for: request, using: matcherClosure)
  }

  func requestDataAndResponse(withIdentifier identifier: String, completion: @escaping (URLRequest?, URLResponse?, Data?) -> Void) {
    dataStorage.loadDataAndResponse(withIdentifier: identifier, completion: completion)
  }

  private func isExcluded(request: URLRequest) -> Bool {
    // Check if request matches any exclusion pattern
    return exclusionList.contains(where: { pattern in
      request.url?.absoluteString.contains(pattern) ?? false
    })
  }

  private func generateIdentifier() -> String {
    // Generate a unique identifier
    return UUID().uuidString
  }

  private func loadJournal(from bundleName: String) -> Journal {
    // Load journal from bundle
    // Implementation details vary based on storage mechanism (e.g., file, database)
    // Return loaded journal
    return Journal()
  }
}

enum Mode {
  case record
  case replay
}

class Journal {
  // Implementation details for managing journal entries
}

class DataStorage {
  // Implementation details for managing data storage
}

//: [Next](@next)
