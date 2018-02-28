# Logger

Simple but controllable logging for Swift.

Declare multiple log channels. Log messages and objects to them. Enable individual channels with minimal overhead for the disabled ones.

### Basic Usage:

```swift

import Logger

let logger = Logger("main")
let detailLogger = Logger("detail")


logger.log("Hello world!")
detailLogger.log("We just logged hello world in the main channel")
```

### Discussion

This is a swift implementation of a pattern I've implemented [a number of times before](http://github.com/elegantchaos/ECLogging). I often use the implementation as a kind of test pattern to learn a language, but I also generally use the library in pretty much everything that I do. 

The main idea is that when debugging complex problems, it's often useful to be able to write extensive logging code. 

It's healthy to be able to leave this code in place, but being able to enable it only when needed - without it having a negative performance impact whilst it's disabled. 

To be able to leave all the logging in place in a large application, and all of its subsystems, you need to be able to separate it into functional areas (which I call channels).

Additional features and/or motivations:

- enabling/disabling channels persistently or at runtime
- logging to console, disk, the network, or anywhere else
- auto-generatating an interface for runtime configuration
- being able to keep some logging in a final release, but dissolve other debug-only stuff away

#### This Version

Motto for this version: "less is more".

Specific aims

- swifty
- simple(r) way to enable/disable channels from the command line
- support the new os_log() model



