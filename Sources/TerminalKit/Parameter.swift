//
//  Parameter.swift
//  TerminalKit
//
//

import Foundation

public protocol Parameter {
    var  name          : String {get}
    var  specification : Specification {get}
    
    mutating func process(validated arguments:[String])
}

extension Array where Element == Parameter {
    var help : String {
        return self.map({ (parameter) -> String in
            parameter.specification.usage(whenNamed: parameter.name)
        }).joined(separator: " ")
    }
}

public enum ParameterError : Error, CustomStringConvertible {
    case notEnough(of:String, expected:Specification)
    
    public var description: String{
        switch self {
        case .notEnough(let parameterName, let specification):
            return "Expected \(specification.description) \(parameterName)"
        }
    }
}

extension Parameter {
    func validate(arguments:[String]) throws -> (validated:[String], remaining:[String]){
        let min = specification.required?.min ?? 0
        let max = specification.required?.max
        
        var remaining = arguments
        var validated = [String]()
        var captured  = 0
        
        while captured < (max ?? Int.max) && !remaining.isEmpty{
            if specification.rightType(remaining[0]) {
                captured += 1
                validated.append(remaining.removeFirst())
            }
        }
        
        if captured < min {
            throw ParameterError.notEnough(of: name, expected: specification)
        }
        
        return (validated, remaining)
    }
}

public enum Required : CustomStringConvertible  {
    case one, oneOrMore, exactly(Int), between(Int, and: Int), upTo(Int), atLeast(Int)
    
    var min : Int {
        switch self {
        case .one, .oneOrMore, .upTo:
            return 1
        case .atLeast(let number), .exactly(let number), .between(let number, _):
            return number
        }
    }
    
    var max : Int? {
        switch self {
        case .one:
            return 1
        case .atLeast, .oneOrMore:
            return nil
        case .exactly(let number), .between(_,let number), .upTo(let number):
            return number
        }
    }
    
    public var description: String{
        switch self {
        case .one:
            return "a"
        case .oneOrMore:
            return "at least"
        case .exactly(let count):
            return "exactly \(count)"
        case .between(let from,let to):
            return "between \(from) and \(to)"
        case .upTo(let limit):
            return "up to \(limit)"
        case .atLeast(let lowerLimit):
            return "more than \(lowerLimit)"
        }
    }
    
    public func usage(withName name:String)->String{
        switch self {
        case .one:
            return name
        case .oneOrMore:
            return "\(name) [\(name) ...]"
        case .exactly(let count):
            return [String](repeating: name, count: count).joined(separator: " ")
        case .atLeast(let count):
            return [String](repeating: name, count: count).joined(separator: " ") + " [\(name) ...]"
        case .between(let from, let to):
            return "\(name)-1 ... \(name)-\(from) [... \(name)-\(to)]"
        case .upTo(let limit):
            return "\(name)-1 [... \(name)-\(limit)]"
        }
    }
}

public enum Specification : CustomStringConvertible {
    case int(Required?), real(Required?), string(Required?)
    
    var  required : Required? {
        switch self {
        case .int(let r), .real(let r), .string(let r):
            return r
        }
    }
    
    public var typeName : String {
        switch self {
        case .int:
            return "integer"
        case .real:
            return "real"
        case .string:
            return "string"
        }
    }
    
    func rightType(_ argument:String?)->Bool {
        guard let argument = argument else {
            return false
        }
        switch self{
        case .int where Int(argument) != nil:
            return true
        case .real where Double(argument) != nil:
            return true
        case .string:
            return true
        default:
            return false
        }
    }
    
    public func usage(whenNamed name:String)->String{
        guard let required = required else {
            return "[\(name)]"
        }
        return required.usage(withName:name)
    }
    
    public var description: String{
        guard let required = required else {
            return ""
        }
        return "\(required) \(typeName)"
    }
}
