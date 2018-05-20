//
//  Flag.swift
//  TerminalKit
//
//

import Foundation

public struct Flag : Option {
    public var longForm: String

    public var shortForm: String?
    
    public var description: String
    
    public let parameters = [Parameter]()
    
    public init(_ longForm:String, shortForm:String? = nil, description:String){
        self.longForm = longForm
        self.shortForm = shortForm
        self.description = description
    }
    
}
