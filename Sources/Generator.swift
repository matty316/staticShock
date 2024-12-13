//
//  Generator.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/12/24.
//

import Foundation
import MarkyMark

struct Generator {
    let siteDir = "site"
    let folder: String
    var styleSheets = [String]()
    var scripts = [String]()
    
    mutating func create() throws {
        let fm = FileManager.default
        let paths = try fm.contentsOfDirectory(atPath: folder)
        try fm.removeItem(atPath: siteDir)
        try fm.createDirectory(atPath: siteDir, withIntermediateDirectories: true)
        try collectStaticFiles()
        for path in paths {
            if isMarkdown(path) {
                try createHTMLFile(path: path)
            } else if isStaticFile(path) {
                try copyFile(path: path)
            } else {
                try createFolder(path: path)
            }
        }
    }
    
    func isStaticFile(_ path: String) -> Bool {
        return isHTML(path) || isJS(path) || isCSS(path)
    }
    
    func isMarkdown(_ path: String) -> Bool {
        return path.hasSuffix(".md")
    }
    
    func isCSS(_ path: String) -> Bool {
        path.hasSuffix(".css")
    }
    
    func isJS(_ path: String) -> Bool {
        path.hasSuffix(".js")
    }
    
    func isHTML(_ path: String) -> Bool {
        path.hasSuffix(".html")
    }
    
    mutating func collectStaticFiles() throws {
        let fm = FileManager.default
        let css = try fm.contentsOfDirectory(atPath: "\(folder)/css/")
            .filter { isCSS($0) }
        let js = try fm.contentsOfDirectory(atPath: "\(folder)/js/")
            .filter { isJS($0) }
        styleSheets.append(contentsOf: css)
        scripts.append(contentsOf: js)
    }
    
    mutating func createFolder(path: String) throws {
        let fm = FileManager.default
        let dirPath = "\(siteDir)/\(path)"
        try fm.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
        let folderPath = "\(folder)/\(path)"
        let paths = try fm.contentsOfDirectory(atPath: folderPath)
        for p in paths {
            let fullPath = "\(path)/\(p)"
            if isMarkdown(fullPath) {
                try createHTMLFile(path: fullPath)
            } else if isStaticFile(fullPath) {
                try copyFile(path: fullPath)
            } else {
                try createFolder(path: fullPath)
            }
        }
    }
    
    func emitStyleSheets() -> String {
        var string = ""
        for ss in styleSheets {
            string.append("<link rel=\"stylesheet\" href=\"css/\(ss)\">")
        }
        return string
    }
    
    func emitScripts() -> String {
        var string = ""
        for s in scripts {
            string.append("<script src=\"js/\(s)\"></script>")
        }
        return string
    }
    
    func createHTMLFile(path: String) throws {
        let fm = FileManager.default
        let input = try String(contentsOfFile: "\(folder)/\(path)", encoding: .utf8)
        let markup = try MarkMark.parse(input)
        let body = markup.elements
            .map { "\t\t\($0.html())" }
            .joined(separator: "\n")
        
        let header = """
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>\(markup.frontMatter["title"] ?? "title")</title>
        \(emitStyleSheets())
    </head>
    <body>
"""
        let footer = """
        \(emitScripts())
    </body>
</html>
"""
        
        let html = """
\(header)
\(body)
\(footer)
"""
        
        let data = html.data(using: .utf8)
        let htmlPath = path.replacingOccurrences(of: ".md", with: ".html")
        fm.createFile(atPath: "\(siteDir)/\(htmlPath)", contents: data)
    }
    
    func copyFile(path: String) throws {
        let fm = FileManager.default
        try fm.copyItem(atPath: "\(folder)/\(path)", toPath: "\(siteDir)/\(path)")
    }
}
