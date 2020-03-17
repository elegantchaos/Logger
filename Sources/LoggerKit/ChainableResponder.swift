// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 17/03/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#if canImport(UIKit) && !os(watchOS)
import UIKit

open class ChainableResponder: UIResponder {
    typealias ResponderFinder = () -> UIResponder?
    
    var getNext: ResponderFinder? = nil
    
    public func install(responder: ChainableResponder) {
        responder.getNext = self.getNext
        self.getNext = { return responder }
    }

    open override var next: UIResponder? {
        return getNext?()
    }
}
#endif
