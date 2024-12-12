//
//  Parser.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

enum ParserError: Error {
    case invalidToken
}

struct Parser {
    let tokens: [Token]
    var position = 0
    var isAtEnd: Bool {
        position >= tokens.count
    }
    var prev: Token {
        tokens[position - 1]
    }
    var current: Token {
        tokens[position]
    }
    
    mutating func parse() throws(ParserError) -> Markup {
        var elements = [Element]()
        while !isAtEnd {
            elements.append(try parseElement())
            advance()
        }
        return Markup(elements: elements)
    }
    
    mutating func parseElement() throws(ParserError) -> Element {
        if match([.star, .plus, .minus]) { return try parseList() }
        return try parseLine()
    }
    
    mutating func parseList() throws(ParserError) -> Element {
        Line(lineType: .h1, content: "")
    }
    
    mutating func parseLine() throws(ParserError) -> Line {
        if match([.hash, .hash2, .hash3, .hash4, .hash5, .hash6]) {
            return try parseHeader()
        }
        return try parseParagraph()
    }
    
    mutating func parseHeader() throws(ParserError) -> Line {
        let type = prev.type
        let text = current.string
        advance()
        
        return switch type {
        case .hash: Line(lineType: .h1, content: text)
        case .hash2: Line(lineType: .h2, content: text)
        case .hash3: Line(lineType: .h3, content: text)
        case .hash4: Line(lineType: .h4, content: text)
        case .hash5: Line(lineType: .h5, content: text)
        case .hash6: Line(lineType: .h6, content: text)
        default: try parseParagraph()
        }
    }
    
    mutating func parseParagraph() throws(ParserError) -> Line {
        let text = current.string
        advance()
        return Line(lineType: .p, content: text)
    }
    
    mutating func advance() {
        if isAtEnd {
            return
        }
        position += 1
    }
    
    mutating func match(_ types: [TokenType]) -> Bool {
        for type in types {
            if current.type == type {
                advance()
                return true
            }
        }
        return false
    }
    
    mutating func expect(_ type: TokenType) throws(ParserError) {
        if current.type == type {
            advance()
        }
        throw .invalidToken
    }
}
