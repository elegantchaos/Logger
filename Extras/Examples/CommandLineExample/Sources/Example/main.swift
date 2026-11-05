// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

/// Signals each message delivered by the asynchronous handler.
let (messages, continuation) = AsyncStream<Void>.makeStream()
/// Prints each delivered message and signals completion.
let handler = BasicHandler("stdout") { item, _ in
  print(item.value)
  continuation.yield(())
}
/// Channel used to demonstrate runtime enablement.
let channel = Channel("Example", handler: handler, default: .enabled)

channel.log("This message is enabled.")
channel.enabled = false
channel.log("This message is disabled and will not be printed.")
channel.enabled = true
channel.log("This message is enabled again.")

/// Number of messages delivered before exiting.
var received = 0
for await _ in messages {
  received += 1
  if received == 2 { break }
}
channel.shutdown()
