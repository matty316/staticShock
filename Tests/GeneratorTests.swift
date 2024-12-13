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
        let path = "/Users/matty/projects/staticShock/website"
        var g = Generator(folder: path)
        try g.create()
        let fm = FileManager.default
        let siteDir = g.siteDir
        let sitePaths = try fm.contentsOfDirectory(atPath: siteDir)
        #expect(sitePaths.contains(where: { $0 == "about.html" }))
        #expect(sitePaths.contains(where: { $0 == "index.html" }))
        #expect(sitePaths.contains(where: { $0 == "css" }))
        #expect(sitePaths.contains(where: { $0 == "js" }))
        let cssPaths = try fm.contentsOfDirectory(atPath: "\(siteDir)/css")
        let jsPaths = try fm.contentsOfDirectory(atPath: "\(siteDir)/js")
        #expect(cssPaths.contains(where: { $0 == "styles.css" }))
        #expect(jsPaths.contains(where: { $0 == "script.js" }))
        
    }
}

