//
//  CommandsForTesting.swift
//  TerminalKitTests
//
//  Created by Nigel Hughes on 21/05/2018.
//



import Foundation
import TerminalKit

protocol TestingCommand : Command {
    init(_ surrogate:BlockCommand)
    var  surrogate : BlockCommand {get}
}

extension TestingCommand {
    init(_ name:String, description : String, options:[Option] = [], parameters : [Parameter] = [], subcommands:[Command] = [], _ block: @escaping BlockCommandClosure){
        self.init(BlockCommand(name: name, description: description, options: options, parameters: parameters, block))
    }
    
    var name: String {
        return surrogate.name
    }
    
    var description: String {
        return surrogate.description
    }
    
    var subCommands: [Command] {
        return surrogate.subCommands
    }
    
    var options: [Option] {
        return surrogate.options
    }
    
    var parameters: [Parameter]{
        return surrogate.parameters
    }
    
    func perform(options: [String : ValidatedParameters], parameters: ValidatedParameters, commandPath: [String]) -> ExitCode {
        return surrogate.perform(options: options, parameters: parameters, commandPath: commandPath)
    }

}

class ParameteredCommand : TestingCommand {
    
    let surrogate: BlockCommand
    
    convenience init() {
        self.init("parametered", description: "A command that takes a parameter", options: [], parameters: [StandardParameter("filename", .string(Required.one))], subcommands: []) { _,_ in return ExitCode.success }
    }

    required init(_ surrogate: BlockCommand) {
        self.surrogate = surrogate
    }
}
