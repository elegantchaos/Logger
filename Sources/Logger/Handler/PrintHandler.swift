// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

/// Outputs log messages using swift's print() function.
let printHandler = BasicHandler("print") { value, context, handler in
  let tag = handler.tag(for: context)
  print("\(tag)\(value)")
}
