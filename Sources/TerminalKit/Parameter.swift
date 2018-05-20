//
//  Parameter.swift
//  TerminalKit
//
//

import Foundation

public protocol Parameter {
    var  name          : String {get}
    var  specification : Specification {get}
    
    func process(validated arguments:[String])
}

extension Array where Element == Parameter {
    var help : String {
        return ""
    }
}

public enum ParameterError : Error {
    case notEnough(of:String, expected:Specification)
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

public enum Required {
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
}

public enum Specification {
    case int(Required?), real(Required?), string(Required?)
    
    var  required : Required? {
        switch self {
        case .int(let r), .real(let r), .string(let r):
            return r
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
}
