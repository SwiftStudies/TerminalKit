//
//  BlockCommand.swift
//  TerminalKit
//
//

import Foundation

public typealias BlockCommandClosure = (_ options: [String : ValidatedParameters], _ parameters: ValidatedParameters)->ExitCode

public struct BlockCommand : Command {
    public var name: String
    public var description: String
    
    public var subCommands: [Command]
    
    public var options: [Option]
    
    public var parameters: [Parameter]
    
    fileprivate var _block : BlockCommandClosure
    
    public init(name:String, description: String, subcommands:[Command] = [], options:[Option], parameters:[Parameter] = [], _ block : @escaping BlockCommandClosure){
        self.name = name
        self.description = description
        self.subCommands = subcommands
        self.options = options
        self.parameters = parameters
        _block = block
    }
    
    public func perform(options: [String : ValidatedParameters], parameters: ValidatedParameters, commandPath:[String]) -> ExitCode {
        return _block(options, parameters)
    }
    
    
}
