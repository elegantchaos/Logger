import Foundation

class LogManager {

  public lazy var enabledLogs : [String] = {
    let defaults = UserDefaults.standard
    guard let logs = defaults.string(forKey: "logs") else {
      return []
    }
    var items = Set(logs.split(separator:","))

    if let additions = defaults.string(forKey: "logs+") {
      let itemsToAdd = Set(additions.split(separator:","))
      items.formUnion(itemsToAdd)
    }

    if let subtractions = defaults.string(forKey: "logs-") {
      let itemsToRemove = Set(subtractions.split(separator:","))
      items.subtract(itemsToRemove)
    }

    defaults.set(logs, forKey: "logs")
    return items.map { return String($0) }
  }()

}
