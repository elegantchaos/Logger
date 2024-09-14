// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// // Created by Sam Deane, 31/01/2018.
// // All code (c) 2018 - present day, Elegant Chaos Limited.
// // For licensing terms, see http://elegantchaos.com/license/liberal/.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Testing

/// Test item that can record when it has been logged.
/// Test log handler which remembers everything that is logged.
actor TestHandler: Handler {

  var logged: [Any] = []
  var continuation: AsyncStream<Any>.Continuation?

  func log(_ value: Sendable, context: Context) async {
    self.logged.append("\(value)")
    continuation?.yield(value)
  }

  func setContinuation(_ continuation: AsyncStream<Any>.Continuation) {
    self.continuation = continuation
  }
  struct Stream: AsyncSequence {
    typealias AsyncIterator = AsyncStream<Any>.Iterator
    typealias Element = Any
    let handler: TestHandler
    func makeAsyncIterator() -> AsyncIterator {
      AsyncStream<Any> { continuation in
        Task {
          await handler.setContinuation(continuation)
        }
      }.makeAsyncIterator()
    }

  }

  var stream: Stream { Stream(handler: self) }
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

struct LoggerTests {
  @Test func name() async throws {
    let handler = TestHandler("test")
    let results = await handler.stream
    let channel = Channel("test", handler: handler, manager: makeTestManager())
    channel.log("test")
    handler.continuation?.finish()
    for await item in results {
      #expect(item as? String == "test")
    }
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
