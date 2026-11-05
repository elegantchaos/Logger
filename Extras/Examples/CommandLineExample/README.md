# Command-Line Example

This example uses Logger from the checkout containing it, including uncommitted changes. From this directory, run:

```sh
swift run Example
```

The example sends messages to a channel with a custom handler and demonstrates enabling and disabling it at runtime. It waits for the enabled messages to reach the handler before exiting.

In a separate project, replace the local path dependency in `Package.swift` with the commented GitHub dependency and choose a suitable released version. See the [Logger README](../../../README.md) for the library's configuration and usage.
