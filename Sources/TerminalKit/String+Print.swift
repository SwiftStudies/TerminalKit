//
//  String+Print.swift
//  TerminalKit
//
//

import Foundation

extension String {
    mutating func print(_ text:String? = nil){
        guard let text = text else {
            return
        }
        self = "\(self)\(text)\n"
    }
}
