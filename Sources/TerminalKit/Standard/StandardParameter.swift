//
//  StandardParameter.swift
//  TerminalKit
//

import Foundation

public struct StandardParameter : Parameter {

    public let name: String
    public let specification: Specification
    public var values : [String]? = nil
    public mutating func process(validated arguments: [String]) {
        values = arguments
    }
    
    public init(_ name:String, _ specification: Specification){
        self.name = name
        self.specification = specification
    }
}
