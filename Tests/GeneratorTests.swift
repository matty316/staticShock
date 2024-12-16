//
//  GeneratorTests.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/13/24.
//

import Foundation
import Testing
@testable import StaticShock

struct GeneratorTests {
    @Test func testGenerateSite() throws {
        let fm = FileManager.default
        let path = Bundle.module.resourcePath!
        print(path)
        var g = Generator(folder: "\(path)/TestData/website")
        try g.create()
        let siteDir = g.siteDir
        let sitePaths = try fm.contentsOfDirectory(atPath: siteDir)
        #expect(sitePaths.contains(where: { $0 == "about.html" }))
        #expect(sitePaths.contains(where: { $0 == "index.html" }))
        #expect(sitePaths.contains(where: { $0 == "test.html" }))
        #expect(!sitePaths.contains(where: { $0 == "header.html" }))
        #expect(!sitePaths.contains(where: { $0 == "footer.html" }))
        #expect(sitePaths.contains(where: { $0 == "css" }))
        #expect(sitePaths.contains(where: { $0 == "js" }))
        let cssPaths = try fm.contentsOfDirectory(atPath: "\(siteDir)/css")
        let jsPaths = try fm.contentsOfDirectory(atPath: "\(siteDir)/js")
        #expect(cssPaths.contains(where: { $0 == "styles.css" }))
        #expect(jsPaths.contains(where: { $0 == "script.js" }))
    }
    
    @Test func testTemplating() throws {
        let input = """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>#(title)</title>
        #(styles)
    </head>
    <body>
        #(scripts)
    </body>
</html>
"""
        let frontMatter = ["title": "test name"]
        let styles = ["styles.css", "base.css", "test.css"]
        let scripts = ["main.js", "test.js", "script.js"]
        let exp = """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>test name</title>
        <link rel="stylesheet" href="css/styles.css"><link rel="stylesheet" href="css/base.css"><link rel="stylesheet" href="css/test.css">
    </head>
    <body>
        <script src="js/main.js"></script><script src="js/test.js"></script><script src="js/script.js"></script>
    </body>
</html>
"""
        let g = Generator(folder: "test")
        let html = try g.template(input: input, frontMatter: frontMatter, styleSheets: styles, scripts: scripts)
        #expect(html == exp)
    }
}

