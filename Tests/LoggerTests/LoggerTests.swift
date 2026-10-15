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
/// The stream never finishes - tests need to break out of it manually when
/// they have completed their checks. This ensures that the test correctly waits
/// for all log output.
func withTestChannel(action: @escaping @Sendable (Channel, StreamHandler) async -> Void)
  throws
  -> LogStream
{
  let st =
    LogStream { continuation in
      let handler = StreamHandler("test", continuation: continuation)
      let manager = Manager(settings: TestSettings())
      let channel = Channel(
        "test", handler: handler, alwaysEnabled: true, manager: manager, autoRun: false)

      // perform the test action(s), then wait for the
      // manager to shut down to ensure all log items have been processed
      Task {
        await action(channel, handler)
        await manager.shutdown()
      }

      // #if LOG_EVENTS
      // monitor the manager event stream and print out the events
      Task {
        for await event in await manager.events {
          print("» \(event)")
        }
        print("events done")
      }
      // #endif
    }

  // return the stream of logged items
  return st
}

struct LoggerTests {
  @Test func testLogging() async throws {
    let output = try withTestChannel { channel, _ in
      channel.log("test")
      print("logged to channel")
    }

    var producedOutput = false
    for try await item in output {
      producedOutput = true
      #expect(item.value as? String == "test")
      break
    }
    #expect(producedOutput)
  }

  @Test func testDisabled() async throws {
    let output = try withTestChannel { channel, _ in
      channel.enabled = false
      channel.log("disabled")
      channel.enabled = true
      channel.log("enabled")
    }

    var producedOutput = false
    for try await item in output {
      producedOutput = true
      #expect(item.value as? String == "enabled")
      break
    }
    #expect(producedOutput)
  }
}
