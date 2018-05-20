//
//  StandardOption.swift
//  TerminalKit
//
//

import Foundation

public struct StandardOption : Option {
    public var longForm: String
    public var shortForm: String?
    public var description: String
    public var parameters: [Parameter]
    
    public init(_ longForm:String, shortForm:String? = nil, description:String, parameters:[Parameter] = []){
        self.longForm = longForm
        self.shortForm = shortForm
        self.description = description
        self.parameters = parameters
    }
    
}
