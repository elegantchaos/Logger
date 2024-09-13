struct Defaults {
  /// Default log handler which prints to standard out, without appending the channel details.
  @MainActor public static let stdoutHandler = PrintHandler(
    "default", showName: false, showSubsystem: false)

  /**
     Default log channel that clients can use to log their actual output.
     This is intended as a convenience for command line programs which actually want to produce output.
     They could of course just use print() for this (producing normal output isn't strictly speaking
     the same as logging), but this channel exists to allow output and logging to be treated in a uniform
     way.

     Unlike most channels, we want this one to default to always being on.
     */

  @MainActor public static let stdout = Channel(
    "stdout", handlers: [stdoutHandler], alwaysEnabled: true)

}
