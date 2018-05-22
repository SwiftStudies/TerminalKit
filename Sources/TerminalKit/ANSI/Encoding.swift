//
//  Encoding.swift
//  TerminalKit
//
//

public protocol ANSICode {
    var sequence : [Int] {get}
}

extension ANSICode {
    public var encoded : String {
        return sequence.map({String($0)}).joined(separator: "")
    }

}

extension Int : ANSICode {
    public var sequence: [Int] {
        return [self]
    }
    
}

extension Array where Element == ANSICode {
    var encodedSequence : String {
        return reduce(ANSI.EscapeSequence.begin, { (result, element) -> String in
            var result = result + (result.isEmpty ? "" : "\(ANSI.EscapeSequence.sequenceSeparator)")
            result += element.encoded
            return result
        })+"\(ANSI.EscapeSequence.sequenceEnd)"
    }
}

extension RawRepresentable where RawValue == Int {
    public var sequence: [Int] {
        return [self.rawValue]
    }
}

public enum ANSI {
    
    public enum TextStyle : Int, ANSICode {
        case none = 0, bold, faint, italic, underline, blink, fastBlink, reverse, conceal, strikeThrough, defaultFont, altFont1, altFont2, altFont3, altFont4, altFont5,altFont6,
        altFont7, altFont8, altFont9, boldOff, normalColor, italicOff, underLineOff, blinkOff,inverseOff, reveal, strikethroughOff
    }
    
    public enum EscapeSequence {
        fileprivate static let begin                : String       =  "\u{001B}["
        fileprivate static let sequenceEnd          : Character    = "m"
        fileprivate static let sequenceSeparator    : Character    = ";"

        
        public static func stripPrefixedCodes(from string: inout String )->[ANSICode]{
            guard string.hasPrefix(EscapeSequence.begin) else {
                return []
            }
            
            let parts = string.split(separator: EscapeSequence.sequenceEnd).map(String.init)

            guard let currentSequence = parts.first else {
                return []
            }

            //TODO: This is not dealing with the case where the code is more than one character
            let oldCodes = currentSequence.replacingOccurrences(of: EscapeSequence.begin, with: "").split(separator: EscapeSequence.sequenceSeparator).compactMap(){
                Int($0)
            }
            
            string = string.replacingOccurrences(of: currentSequence+"\(EscapeSequence.sequenceEnd)", with: "")
            
            return oldCodes
        }
    }
    
}

public extension String {
    public init(with code:ANSICode){
        self.init(code.sequence.reduce("", {$0+String($1)}))
    }

    public var bold : String {
        return ANSI.TextStyle.bold.applyTo(self)
    }
    
    public var italic : String {
        return ANSI.TextStyle.italic.applyTo(self)
    }
    
    public func style(_ style:ANSI.TextStyle)->String{
        return style.applyTo(self)
    }
}



public extension ANSICode {
    
    public func applyTo(_ string:String)->String{
        var string = string
        
        var codes = ANSI.EscapeSequence.stripPrefixedCodes(from: &string)
        
        // Set the style to none at the end, unless it's already on the string
        var formatUpperBound = [ANSI.TextStyle.none].encodedSequence
        if string.hasSuffix(formatUpperBound) {
            formatUpperBound = ""
        }
        
        codes.append(contentsOf: self.sequence)
        
        return codes.encodedSequence + string + formatUpperBound
    }
    

}

