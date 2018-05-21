//
//  Command.swift
//  TerminalKit
//
//

import Foundation

public typealias ValidatedParameters = [String : [String]]

public protocol Command {
    var name : String {get}
    var description : String {get}
    var subCommands : [Command] {get}
    var options     : [Option] {get}
    var parameters  : [Parameter] {get}
    
    func perform(options: [String : ValidatedParameters], parameters: ValidatedParameters, commandPath:[String]) -> ExitCode
}

public enum CommandError : Error, CustomStringConvertible{
    case invalidParametersForOption(Error, Command, [String], Option)
    case invalidParametersForCommand(Error, Command, [String])
    
    public var description: String{
        switch self {
        case .invalidParametersForCommand(let error, let forCommand, _):
            return "Invalid parameters processing command \(forCommand.name): \(error)"
        case .invalidParametersForOption(let error, let forCommand, _, let option):
            return "Invalid parameters processing option of command \(forCommand.name), --\(option.longForm): \(error)"
        }
    }
}

extension Command {
    public func usage(command path:[String]) -> String {
        var message = ""
        message.print(description)
        message.print()
        
        message.print("Usage: \(path.joined(separator: " "))\(options.isEmpty ? " " : " [options] ")\(parameters.help)")
        message.print()
        
        if !subCommands.isEmpty {
            message.print("Subcommands")
            for subcommand in subCommands {
                message.print("\t\(subcommand.name)")
            }
            message.print()
        }
        
        if !options.isEmpty {
            message.print("Options")
            for option in options {
                message.print(option.help)
            }
        }
        
        return message
    }
    
    func execute(arguments:[String],commandPath:[String]) throws -> ExitCode{
        // Add myself to the command path
        var commandPath = commandPath
        commandPath.append(self.name)

        //Give any subcommands the chance to operate on the arguments first
        if let candidateSubCommand = arguments.first {
            for command in subCommands {
                if command.name == candidateSubCommand {
                    let arguments = arguments.dropFirst()
                    return try command.execute(arguments: Array<String>(arguments.dropFirst()), commandPath: commandPath)
                }
            }
        }

        // Display help if it's requested
        if arguments.contains("--help"){
            print(usage(command: commandPath))
            ExitCode.success.exit()
        }
        
        // Otherwise start parsing
        var arguments = arguments
        
        //If none of the subcommands processed the command line then look for my options and parameters
        var optionValues = [String : ValidatedParameters]()
        for option in options {
            if let candidateOption = arguments.first {
                if "--\(option.longForm)" == candidateOption || "-\(option.shortForm ?? "🤬")" == candidateOption {
                    do {
                        let results = try option.parse(arguments: [String](arguments.dropFirst()))
                        arguments = results.remaining
                        optionValues[option.longForm] = results.parameters
                    } catch {
                        throw CommandError.invalidParametersForOption(error, self, commandPath, option)
                    }
                }
            }
        }
        
        var parameterValues = [String:[String]]()
        for parameter in parameters {
            do {
                let parseResults = try parameter.validate(arguments: arguments)
                arguments = parseResults.remaining
                parameterValues[parameter.name] = parseResults.validated
            } catch {
                throw CommandError.invalidParametersForCommand(error, self, commandPath)
            }
        }
        
        return perform(options: optionValues, parameters: parameterValues, commandPath: commandPath)
    }

}
