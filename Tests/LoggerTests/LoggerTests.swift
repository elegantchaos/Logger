// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// // Created by Sam Deane, 31/01/2018.
// // All code (c) 2018 - present day, Elegant Chaos Limited.
// // For licensing terms, see http://elegantchaos.com/license/liberal/.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Testing

/// Test log handler which yields items to an async stream.
actor TestHandler: Handler {
  internal init(logged: [Any] = [], continuation: AsyncStream<any Sendable>.Continuation) {
    self.continuation = continuation
  }

  let name = "test"
  let continuation: AsyncStream<Sendable>.Continuation

  func log(_ value: Sendable, context: Context) async {
    print("logged: \(value)")
    continuation.yield(value)
  }

}

struct Sequence2: AsyncSequence {
  typealias AsyncIterator = AsyncStream<Sendable>.Iterator
  typealias Element = Sendable
  let action: @Sendable (AsyncStream<Sendable>.Continuation) throws -> Void

  func makeAsyncIterator() -> AsyncStream<any Sendable>.Iterator {
    print("making stream")
    let s =
      AsyncStream<Sendable> { continuation in
        do {
          try action(continuation)
        } catch {
          continuation.finish()
          print(error)
        }
      }

    print("returning iterator")
    return s.makeAsyncIterator()
  }
}

struct EmptyManagerSettings: ManagerSettings {
  var enabledChannelIDs: Set<Channel.ID> { [] }
  func saveEnabledChannelIDs(_: Set<Channel.ID>) {}
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
    arguments
  }
}

func makeTestManager() -> Manager {
  return Manager(settings: EmptyManagerSettings())
}

func withTestChannel(activity: @escaping @Sendable (TestHandler, Channel) async throws -> Void)
  throws
  -> Sequence2
{
  let s = Sequence2 { continuation in
    Task {
      let handler = TestHandler(continuation: continuation)
      let channel = Channel(
        "test", handler: handler, alwaysEnabled: true, manager: makeTestManager())
      try await activity(handler, channel)
      print("done activity")
      continuation.finish()
      print("finished")
    }
  }
  return s
}

struct LoggerTests {
  @Test func name() async throws {
    let output = try withTestChannel { handler, channel in
      print("A1")
      channel.log("test")
      print("A2")
    }

    for await item in output {
      print("B \(item)")
      #expect(item as? String == "test")
      print("C")
    }

    print("done loop")

  }
}

// #if !os(watchOS)
//   import Foundation
//   import LoggerTestSupport
//   import Testing

//   @testable import Logger

//   /**
//  Test item that fulfills an expectation when it's logged.
//  */

//   struct TestItem: CustomStringConvertible {
//     let test: XCTestCase
//     let expectation = XCTestExpectation(description: "logged")
//     let message: String

//     init(_ message: String, test: XCTestCase) {
//       self.message = message
//       self.test = test
//     }

//     var description: String {
//       message
//     }

//     func logged() {
//       expectation.fulfill()
//     }

//     func wait() {
//       test.wait(for: [expectation], timeout: 1.0)
//     }
//   }

//   /**
//  Test log handler that keeps a list of the things its logged.
//  */

//   struct EmptyManagerSettings: ManagerSettings {
//     var enabledChannelIDs: Set<Channel.ID> { [] }
//     func saveEnabledChannelIDs(_: Set<Channel.ID>) {}
//     func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
//       arguments
//     }
//   }

//   /**
//  Tests
//  */

//   struct LoggerTests {
//     func makeTestManager() -> Manager {
//       Manager(settings: EmptyManagerSettings())
//     }

//     func makeItem(_ message: String) -> TestItem {
//       TestItem(message, test: self)
//     }

//     func blankDefaults() -> UserDefaults {
//       let defaults = UserDefaults(suiteName: "LoggerTests")!
//       defaults.removePersistentDomain(forName: "LoggerTests")
//       return defaults
//     }

//     @Test
//     func testLoggingEnabled() async throws {
//       let item = makeItem("blah")
//       let handler = TestHandler("test")
//       let channel = Channel("test", handlers: [handler], manager: makeTestManager())
//       channel.enabled = true
//       channel.log(item)
//       item.wait()
//       #expect(handler.logged.count == 1)
//       #expect(handler.logged[0] as! String == "blah")
//     }

//     @Test
//     func testLoggingDisabled() async throws {
//       let handler = TestHandler("test")
//       let channel = Channel("test", handlers: [handler], manager: makeTestManager())
//       channel.enabled = false
//       channel.log("blah")
//       #expect(handler.logged.count == 0)
//     }

//     @Test
//     func testDebugLogging() async throws {
//       let item = makeItem("logged")
//       let handler = TestHandler("test")
//       let channel = Channel("test", handlers: [handler], manager: makeTestManager())
//       channel.enabled = true
//       channel.debug("debug-only")
//       channel.log(item)
//       item.wait()

//       #if DEBUG
//         #expect(handler.logged.first as! String == "debug-only")
//       #else
//         #expect(handler.logged.first as! String == "logged")
//       #endif
//     }

//     @Test
//     func testContextDescription() async throws {
//       let c = Context(file: "test.swift", line: 123, column: 456, function: "testFunc")
//       #expectEqual(c.description, "test.swift: 123,456 - testFunc")
//     }

//     @Test
//     func testChannelSimpleName() async throws {
//       let channel = Channel("simpleName")
//       #expectEqual(channel.name, "simpleName")
//       #expectEqual(channel.subsystem, Channel.defaultSubsystem)
//     }

//     @Test
//     func testChannelComplexName() async throws {
//       let channel = Channel("com.elegantchaos.logger.test.name")
//       #expectEqual(channel.name, "name")
//       #expectEqual(channel.subsystem, "com.elegantchaos.logger.test")
//     }

//     @Test
//     func testChannelComparison() async throws {
//       let channel1 = Channel("test")
//       let channel2 = Channel("test")
//       #expectEqual(channel1, channel2)
//       #expectEqual(channel1.hashValue, channel2.hashValue)
//     }

//     @Test
//     func testHandlerComparison() async throws {
//       let h1 = Handler("test")
//       let h2 = Handler("test")
//       #expectEqual(h1, h2)
//       #expectEqual(h1.hashValue, h2.hashValue)
//     }

//     #if !os(iOS)
//       func testFatalError() async throws {
//         let manager = makeTestManager()
//         let logged =
//           #expectFatalError(manager: manager) {
//             let channel = Channel("test", manager: manager)
//             channel.fatal("Oh bugger")
//           } as? String

//         #expectEqual(logged, "Oh bugger")
//       }
//     #endif
//   }
// #endif
