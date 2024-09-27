// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// // Created by Sam Deane, 31/01/2018.
// // All code (c) 2018 - present day, Elegant Chaos Limited.
// // For licensing terms, see http://elegantchaos.com/license/liberal/.
// // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger
import Testing

/// Settings supplier for the tests.
struct TestSettings: ManagerSettings {
  var enabledChannelIDs: Set<Channel.ID> { [] }
  func saveEnabledChannelIDs(_: Set<Channel.ID>) {}
  func removeLoggingOptions(fromCommandLineArguments arguments: [String]) -> [String] {
    arguments
  }
}

/// Set up a test channel and handler, and perform some action(s) with it.
/// The result of the call is an asynchronous stream containing the
/// items that were logged to the channel.
func withTestChannel(action: @escaping @Sendable (Channel, StreamHandler) async throws -> Void)
  throws
  -> LogStream
{
  let st =
    LogStream { continuation in
      Task {
        do {
          let handler = StreamHandler("test", continuation: continuation)
          let manager = Manager(settings: TestSettings())
          let channel = Channel(
            "test", handler: handler, alwaysEnabled: true, manager: manager, autoRun: false)
          print("running action")
          try await action(channel, handler)
          print("done")
          await channel.shutdown()
          await channel.run()
          print("flushed")
          await handler.finish()
        } catch {
          continuation.finish(throwing: error)
        }
      }
    }

  print("returned stream")
  return st
}

struct LoggerTests {
  @Test func testLogging() async throws {
    let output = try withTestChannel { channel, _ in
      channel.log("test")
    }

    var count = 0
    for try await item in output {
      print("A")
      count += 1
      #expect(item as? String == "test")
    }
    #expect(count == 1)
  }

  // @Test func testDisabled() async throws {
  //   let output = try withTestChannel { channel, _ in
  //     channel.enabled = false
  //     channel.log("test")
  //   }

  //   for try await _ in output {
  //     fatalError("channel should have no output")
  //   }
  // }
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
