# Logger

Configurable logging for Swift.

Declare multiple log channels. 
Log messages and objects to them. 
Enable individual channels with minimal overhead for the disabled ones.

### Basic Usage:

Just import the module and make one or more channels.

```swift

import Logger

let logger = Logger("com.acme.example.main")
let detailLogger = Logger("com.acme.example.detail")
````

To log output, just write it to a channel. Different kinds or levels of info can go to different channels as required:

```swift
logger.log("Hello world!")
detailLogger.log("We just logged hello world in the main channel")
```

To log for debug builds only:

```swift
logger.debug("This will never show up in a release build")
```

To enable specific channels when you run:

```
.build/debug/Example -logs "main"
```

To enable channels persistently:

```
defaults write com.acme.Example logs "main, detail"
```

To enable/disable additional channels when you run, without wiping out the previous persistent settings: 

```
.build/debug/Example -logs+ "detail"  # runs with the previous channel config, but the detail channel also enabled
.build/debug/Example -logs- "detail"  # runs with the previous channel config, but the detail channel disabled
```





### Discussion

This is a swift version of a pattern I've implemented [a number of times before](http://github.com/elegantchaos/ECLogging). I often use it as a kind of test project to learn a language with, but I also use the library functionality in pretty much everything that I do. 

The main idea is that when debugging complex problems, it's often useful to be able to write extensive logging code. 

It's healthy to be able to leave this code in place, but enable it only when needed. It's useful to be able to do this at runtime, sometimes even in release versions, without disabled logging code having a negative performance impact. 

For this to scale to a large application with many subsystems, you need to be able to separate log output into functional areas, so that you can look only at the bit you're interested in.

Additional features and/or motivations:

- enabling/disabling channels persistently or at runtime
- logging to console, disk, the network, or anywhere else
- auto-generatating an interface for runtime configuration
- being able to keep some logging in a final release, but dissolve other debug-only stuff away

#### This Version

Motto for this version: "less is more". The implementation of ECLogging started getting a bit gnarly.

Specific aims

- swifty
- simple(r) way to enable/disable channels from the command line
- support the new os_log() model



