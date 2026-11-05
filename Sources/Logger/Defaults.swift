struct Defaults {

  /**
     Default log channel that clients can use to log their actual output.
     This is intended as a convenience for command line programs which actually want to produce output.
     They could of course just use print() for this (producing normal output isn't strictly speaking
     the same as logging), but this channel exists to allow output and logging to be treated in a uniform
     way.

     Unlike most channels, this one is enabled unless it has been disabled.
     */

  public static let stdout = Channel(
    "stdout", handler: printHandler, default: .enabled)

}
