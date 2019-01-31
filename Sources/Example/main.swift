// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 27/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Logger

let stdout = Logger.stdout

let test = Channel("test")
let test2 = Channel("com.elegantchaos.other.test2", handlers: [PrintHandler("print", showName: true, showSubsystem: true)])

stdout.log("This should get printed to stdout.")
stdout.log("There shouldn't be any contex information included in the output.\n")

test.log("This should get printed to the default console location.")
test.log("On the Mac it'll be the console. On Linux, currently, it's stdout.")
test.log("Unlike the Logger.stdout channel, this one also shows the channel name.\n\n")

test2.log("This should always be logged to stdout, but will show the console name and the subsystem.\n")

stdout.debug("This should only appear for debug builds.\n")

Logger.defaultManager.flush()
