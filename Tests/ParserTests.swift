//
//  ParserTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import StaticShock

struct ParserTests {
    func parse(input: String) throws -> Markup {
        var scanner = Scanner(input: input)
        var parser = Parser(tokens: try scanner.scan())
        return try parser.parse()
    }
    
    @Test func parseHeading() throws {
        let markup = try parse(input: """
# heading 1
## heading 2
### heading 3
#### heading 4
##### heading 5
###### heading 6
####### not a heading
""")
        
        let elements = markup.elements
        let h1 = elements[0] as! Line
        let h2 = elements[1] as! Line
        let h3 = elements[2] as! Line
        let h4 = elements[3] as! Line
        let h5 = elements[4] as! Line
        let h6 = elements[5] as! Line
        let p = elements[6] as! Line
        
        #expect(h1.lineType == .h1)
        #expect(h2.lineType == .h2)
        #expect(h3.lineType == .h3)
        #expect(h4.lineType == .h4)
        #expect(h5.lineType == .h5)
        #expect(h6.lineType == .h6)
        #expect(p.lineType == .p)
        #expect(h1.content == "heading 1")
        #expect(h2.content == "heading 2")
        #expect(h3.content == "heading 3")
        #expect(h4.content == "heading 4")
        #expect(h5.content == "heading 5")
        #expect(h6.content == "heading 6")
        #expect(p.content == "####### not a heading")
    }
}
