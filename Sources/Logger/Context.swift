// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// Created by Sam Deane, 15/02/2018.
// All code (c) 2018 - present day, Elegant Chaos Limited.
// For licensing terms, see http://elegantchaos.com/license/liberal/.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public class Context : CustomStringConvertible {
    let file: String
    let line : Int
    let function : String
    let column : Int
    let dso : UnsafeRawPointer
    
    public init(file: String = #file, line: Int = #line,  column: Int = #column, function: String = #function, dso: UnsafeRawPointer = #dsohandle) {
        self.file = file
        self.line = line
        self.function = function
        self.column = column
        self.dso = dso
    }
    
    public var description: String { get {
        return "\(file): \(line),\(column) - \(function)"
        }
    }
}
