// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS) || os(iOS)
  import Foundation

  ///  Outputs log messages using NSLog()
  let nslogHandler = BasicHandler("nslog") {
    value, context, handler in
    let tag = handler.tag(for: context)
    NSLog("\(tag)\(value)")
  }

#endif
