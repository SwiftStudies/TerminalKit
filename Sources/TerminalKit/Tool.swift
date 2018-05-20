//
//  Application.swift
//  TerminalKit
//
//
import Foundation

public enum ExitCode {
    case success
    case failed(reason:String)
    case customFailure(code:Int, reason:String)
    
    public func exit(){
        switch self {
        case .success:
            Darwin.exit(EXIT_SUCCESS)
        case .failed(let reason):
            print(reason)
            Darwin.exit(EXIT_FAILURE)
        case .customFailure(let code, let reason):
            print(reason)
            Darwin.exit(Int32(code))
        }
    }
}

public struct Tool {
    let version : String
    let description : String
    let commands : [Command]
    
    public init(version:String, description:String, commands:[Command]){
        assert(commands.count > 0)
        self.version = version
        self.description = description
        self.commands = commands
    }
    
    public func run(_ arguments:[String]) throws {
        var arguments = arguments
        
        if !arguments.isEmpty {
            for command in commands {
                if command.name == arguments[0] {
                    try command.execute(arguments: [String](arguments.dropFirst())).exit()
                }
            }
        }
        
        try commands[0].execute(arguments: arguments).exit()
    }
}
