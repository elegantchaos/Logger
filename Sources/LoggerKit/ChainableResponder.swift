// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

// TODO: should probably move this to its own package, as it's not really related to logging.

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A responder which can accept other responders to install into the chain.

open class ChainableResponder: UIResponder {

    typealias ResponderFinder = () -> UIResponder?

    /// A block which obtains the next responder.
    var getNext: ResponderFinder? = nil
    
    /// Install another responder into the chain.
    /// The new responder will become our next responder.
    /// Any previous next responder will become the next responder of the new responder.
    /// The responder we're passed should not have already been installed into a chain.
    public func install(responder: ChainableResponder) {
        assert(responder.getNext == nil)
        responder.getNext = self.getNext
        self.getNext = { return responder }
    }

    /// Returns the next responder.
    open override var next: UIResponder? {
        return getNext?()
    }
    
    /// Returns the responder chain from this object onwards.
    open var chain: [ChainableResponder] {
        var result: [ChainableResponder] = []
        var responder: ChainableResponder = self
        repeat {
            result.append(responder)
            guard let next = responder.next as? ChainableResponder else {
                break
            }
            responder = next
        } while true

        return result
    }
}
#endif
