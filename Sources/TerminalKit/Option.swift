//
//  Option.swift
//  TerminalKit
//
//

import Foundation

public protocol Option {
    var longForm : String {get}
    var shortForm : String? {get}
    var description : String {get}
    var parameters : [Parameter] {get}
}

extension Option {
    var help : String {
        var message = ""
        message.print("\t--\(longForm)\(shortForm != nil ? "": "") \(parameters.help)")
        message.print("\t\(description)")
        message.print()
        
        return message
    }
    
    func parse(arguments:[String]) throws -> (remaining: [String], parameters:ValidatedParameters) {
        var arguments = arguments
        var parameterValues = [String:[String]]()
        
        for parameter in parameters {
            let parseResults = try parameter.validate(arguments: arguments)
            arguments = parseResults.remaining
            parameterValues[parameter.name] = parseResults.validated
        }
        
        return (remaining: arguments, parameters: parameterValues)
    }
}
