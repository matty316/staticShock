//
//  Markup.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

struct Markup {
    let elements: [Element]
}

protocol Element {
    
}

enum LineType {
    case h1, h2, h3, h4, h5, h6, p, unorderedListItem, orderedListItem
}

struct Line: Element {
    let lineType: LineType
    let content: String
}

struct List: Element {
    let lines: [Line]
}
