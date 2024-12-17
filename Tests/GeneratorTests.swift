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
        #expect(sitePaths.contains(where: { $0 == "test-page.html" }))
        #expect(sitePaths.contains(where: { $0 == "blog.html" }))
        #expect(!sitePaths.contains(where: { $0 == "posts" }))
        #expect(!sitePaths.contains(where: { $0 == "header.html" }))
        #expect(!sitePaths.contains(where: { $0 == "footer.html" }))
        #expect(!sitePaths.contains(where: { $0 == "post.html" }))
        #expect(sitePaths.contains(where: { $0 == "css" }))
        #expect(sitePaths.contains(where: { $0 == "js" }))
        #expect(sitePaths.contains(where: { $0 == "test-post.html" }))
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
    
    @Test func testBlog() throws {
        let path = Bundle.module.resourcePath!
        var g = Generator(folder: "\(path)/TestData/website", siteDir: "blogTest")
        try g.create()
        let siteDir = g.siteDir
        let contents = try String(contentsOfFile: "\(siteDir)/blog.html", encoding: .utf8)
        let exp = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>blog</title>
    <link rel="stylesheet" href="css/styles.css"><link rel="stylesheet" href="css/bulma.min.css">
</head>
<body>
    <div class="container">
        <nav class="navbar">
            <a href="index.html" class="navbar-item">home</a>
            <a href="about.html" class="navbar-item">about</a>
            <a href="blog.html" class="navbar-item">blog</a>
        </nav>
        <div class="content">
<div class="card">
    <div class="card-content content"><a href="test-post.html"><h1>test post</h1></a><p>this is a short description</p></div>
</div>

</div>
</div>
<script src="js/script.js"></script>
</body>
</html>
"""
        #expect(contents == exp)
    }
    
    @Test func testHTML() throws {
        let path = Bundle.module.resourcePath!
        var g = Generator(folder: "\(path)/TestData/website", siteDir: "htmlTest")
        try g.create()
        let siteDir = g.siteDir
        let contents = try String(contentsOfFile: "\(siteDir)/test-page.html", encoding: .utf8)
        
        let exp = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Test Page</title>
    <link rel="stylesheet" href="css/styles.css"><link rel="stylesheet" href="css/bulma.min.css">
</head>
<body>
    <div class="container">
        <nav class="navbar">
            <a href="index.html" class="navbar-item">home</a>
            <a href="about.html" class="navbar-item">about</a>
            <a href="blog.html" class="navbar-item">blog</a>
        </nav>
        <div class="content">

<h1>heading</h1>        
<p>will it copy???</p>


</div>
</div>
<script src="js/script.js"></script>
</body>
</html>
"""
        #expect(contents == exp)
    }
}

