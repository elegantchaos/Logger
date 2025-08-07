// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 27/09/24.
//  All code (c) 2024 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if os(macOS) || os(iOS)
  import Foundation

  ///  Outputs log messages using NSLog()
  let nslogHandler = BasicHandler("nslog") {
    item, handler in
    let tag = await handler.tag(for: item.context)
    NSLog("\(tag)\(item.value)")
  }

#endif
