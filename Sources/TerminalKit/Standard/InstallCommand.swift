//
//  InstallCommand.swift
//  TerminalKit
//
//

import Foundation

public struct InstallCommand : Command {
    public let name = "install"
    
    public let description = "Installs the command line tool into /usr/local/bin (can be overridden)."
    
    public let subCommands: [Command] = []
    
    public let options: [Option] = [
        StandardOption("location", description: "Override the default install location of /usr/local/bin/", parameters: [
                StandardParameter("directory", Specification.string(Required.one))
            ])
    ]
    
    public let parameters: [Parameter] = []
    
    public init(){
        
    }
    
    public func perform(options: [String : ValidatedParameters], parameters: ValidatedParameters, commandPath:[String]) -> ExitCode {
        
        let installLocation : String
        
        if let locationOption = options[self.options[0].longForm] {
            installLocation = locationOption["directory"]![0]
        } else {
            installLocation = "/usr/local/bin/"
        }
        
        let result = bash(command: "cp", arguments: ["-v",CommandLine.arguments[0],installLocation])
        
        print("Installing\n\t",result)
        
        return ExitCode.success
    }
    
    /// Taken from [StackOverflow](https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild)
    private func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.count > 0 {
            //remove newline character.
            let lastIndex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIndex])
        }
        return output
    }
    
    /// Taken from [StackOverflow](https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild)
    private func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(launchPath: whichPathForCommand, arguments: arguments)
    }
}
