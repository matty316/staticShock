//
//  ScannerTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Testing
@testable import StaticShock

struct ScannerTests {
    @Test func testScan() throws {
        let input = """
#*=-_.+`\n[]\r\n()<>!\\
# ## ### #### ##### ######
- -- ---
* ** ***
_ __ ___
` `` ```

word 2 23
2
23
####### not a heading
"""
        let exp = [
            Token(string: "#", line: 1, type: .hash),
            Token(string: "*", line: 1, type: .star),
            Token(string: "=", line: 1, type: .equal),
            Token(string: "-", line: 1, type: .minus),
            Token(string: "_", line: 1, type: .underscore),
            Token(string: ".", line: 1, type: .dot),
            Token(string: "+", line: 1, type: .plus),
            Token(string: "`", line: 1, type: .tick),
            Token(line: 1, type: .lineEnding),
            Token(string: "[", line: 2, type: .lbracket),
            Token(string: "]", line: 2, type: .rbracket),
            Token(line: 2, type: .lineEnding),
            Token(string: "(", line: 3, type: .lparen),
            Token(string: ")", line: 3, type: .rparen),
            Token(string: "<", line: 3, type: .lt),
            Token(string: ">", line: 3, type: .gt),
            Token(string: "!", line: 3, type: .bang),
            Token(string: "\\", line: 3, type: .backslash),
            Token(line: 3, type: .lineEnding),
            Token(line: 4, type: .hash),
            Token(line: 4, type: .hash2),
            Token(line: 4, type: .hash3),
            Token(line: 4, type: .hash4),
            Token(line: 4, type: .hash5),
            Token(line: 4, type: .hash6),
            Token(line: 4, type: .lineEnding),
            Token(line: 5, type: .minus),
            Token(line: 5, type: .minus2),
            Token(line: 5, type: .minus3),
            Token(line: 5, type: .lineEnding),
            Token(line: 6, type: .star),
            Token(line: 6, type: .star2),
            Token(line: 6, type: .star3),
            Token(line: 6, type: .lineEnding),
            Token(line: 7, type: .underscore),
            Token(line: 7, type: .underscore2),
            Token(line: 7, type: .underscore3),
            Token(line: 7, type: .lineEnding),
            Token(line: 8, type: .tick),
            Token(line: 8, type: .tick2),
            Token(line: 8, type: .tick3),
            Token(line: 8, type: .lineEnding),
            Token(line: 9, type: .lineEnding),
            Token(string: "word 2 23", line: 10, type: .text),
            Token(line: 10, type: .lineEnding),
            Token(string: "2", line: 11, type: .num),
            Token(line: 11, type: .lineEnding),
            Token(string: "23", line: 12, type: .num),
            Token(line: 12, type: .lineEnding),
            Token(string: "####### not a heading", line: 13, type: .text),
            Token(line: 13, type: .eof)
        ]
        
        var s = Scanner(input: input)
        let tokens = try s.scan()
        for (i, token) in tokens.enumerated() {
            let expToken = exp[i]
            #expect(token.line == expToken.line)
            #expect(token.string == expToken.string)
            #expect(token.type == expToken.type)
        }
    }
}
