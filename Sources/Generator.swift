//
//  Generator.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/12/24.
//

import Foundation
import MarkyMark

enum GeneratorError: Error {
    case missingVar
    case unterminated
}

struct Generator {
    let siteDir: String
    let folder: String
    let postsDir: String
    var styleSheets = [String]()
    var scripts = [String]()
    
    init(folder: String, siteDir: String? = nil, postsDir: String? = nil) {
        self.folder = folder
        self.siteDir = siteDir ?? "site"
        self.postsDir = postsDir ?? "posts"
    }
    
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
            } else if isHTML(path) {
                if !isHeader(path) && !isFooter(path) {
                    try copyHTML(path: path)
                }
            } else {
                try createFolder(path: path)
            }
        }
    }
    
    func template(input: String,
                  frontMatter: [String: String],
                  styleSheets: [String],
                  scripts: [String]) throws(GeneratorError) -> String {
        var newString = input
        while let range = newString.range(of: "#(") {
            guard let rParen = newString[range.upperBound...].range(of: ")") else {
                throw .unterminated
            }
            let string = String(newString[range.upperBound..<rParen.lowerBound])
            if let val = frontMatter[string] {
                newString = newString.replacingCharacters(in: range.lowerBound..<rParen.upperBound, with: val)
            } else if string == "styles" {
                newString = newString
                    .replacingCharacters(in: range.lowerBound..<rParen.upperBound,
                                         with: emitStyleSheets(styleSheets: styleSheets))
            } else if string == "scripts" {
                newString = newString
                    .replacingCharacters(in: range.lowerBound..<rParen.upperBound,
                                         with: emitScripts(scripts: scripts))
            } else {
                throw .missingVar
            }
        }
        return newString
    }
    
    func isStaticFile(_ path: String) -> Bool {
        return isJS(path) || isCSS(path)
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
    
    func isHeader(_ path: String) -> Bool {
        path.hasSuffix("header.html")
    }
    
    func isFooter(_ path: String) -> Bool {
        path.hasSuffix("footer.html")
    }
    
    func getHeader(frontMatter: [String: String]) throws -> String {
        let string = try String(contentsOfFile: folder + "/header.html", encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return try template(input: string, frontMatter: frontMatter, styleSheets: styleSheets, scripts: scripts)
    }
    
    func getFooter(frontMatter: [String: String]) throws -> String {
        let string = try String(contentsOfFile: folder + "/footer.html", encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return try template(input: string, frontMatter: frontMatter, styleSheets: styleSheets, scripts: scripts)
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
    
    func emitStyleSheets(styleSheets: [String]) -> String {
        var string = ""
        for ss in styleSheets {
            string.append("<link rel=\"stylesheet\" href=\"css/\(ss)\">")
        }
        return string
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func emitScripts(scripts: [String]) -> String {
        var string = ""
        for s in scripts {
            string.append("<script src=\"js/\(s)\"></script>")
        }
        return string
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func createHTMLFile(path: String) throws {
        let fm = FileManager.default
        let input = try String(contentsOfFile: "\(folder)/\(path)", encoding: .utf8)
        let markup = try MarkMark.parse(input)
        let body = markup.html()
        let header = try getHeader(frontMatter: markup.frontMatter)
        let footer = try getFooter(frontMatter: markup.frontMatter)
        
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
    
    func copyHTML(path: String) throws {
        let string = try String(contentsOfFile: "\(folder)/\(path)", encoding: .utf8)
        let newString = try template(input: string, frontMatter: [:], styleSheets: styleSheets, scripts: scripts)
        try newString.write(toFile: "\(siteDir)/\(path)", atomically: true, encoding: .utf8)
    }
}
