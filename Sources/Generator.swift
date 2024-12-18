//
//  Generator.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/12/24.
//

import Foundation
import MarkyMark

enum GeneratorError: Error {
    case missingVar(String, String)
    case unterminatedVar
}

struct Generator {
    let siteDir: String
    let folder: String
    let postsDir: String
    var styleSheets = [String]()
    var scripts = [String]()
    var posts = [String]()
    
    init(folder: String, siteDir: String? = nil, postsDir: String? = nil) {
        self.folder = folder
        self.siteDir = siteDir ?? "site"
        self.postsDir = postsDir ?? "posts"
    }
    
    mutating func create() throws {
        let fm = FileManager.default
        let paths = try fm.contentsOfDirectory(atPath: folder)
        if fm.fileExists(atPath: siteDir) {
            try fm.removeItem(atPath: siteDir)
        }
        try fm.createDirectory(atPath: siteDir, withIntermediateDirectories: true)
        try collectStaticFiles()
        for path in paths {
            var isDir: ObjCBool = false
            fm.fileExists(atPath: "\(folder)/\(path)", isDirectory: &isDir)
            if isDir.boolValue {
                if isPostsDir(path) {
                    try createBlog()
                } else {
                    try createFolder(path: path)
                }
            } else if isMarkdown(path) {
                try createHTMLFile(path: path)
            } else if isHTML(path) {
                if !isHeader(path) && !isFooter(path) && !isPostTemplate(path) {
                    try copyHTML(path: path)
                }
            } else {
                try copyFile(path: path)
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
                throw .unterminatedVar
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
                newString = newString
                    .replacingCharacters(in: range.lowerBound..<rParen.upperBound, with: "")
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
        path == "header.html"
    }
    
    func isFooter(_ path: String) -> Bool {
        path == "footer.html"
    }
    
    func isPostsDir(_ path: String) -> Bool {
        path == postsDir
    }
    
    func isPostTemplate(_ path: String) -> Bool {
        path == "post.html"
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
        styleSheets = try fm.contentsOfDirectory(atPath: "\(folder)/css/")
            .filter { isCSS($0) }
        scripts = try fm.contentsOfDirectory(atPath: "\(folder)/js/")
            .filter { isJS($0) }
        posts = try fm.contentsOfDirectory(atPath: "\(folder)/posts")
            .filter { isMarkdown($0) }
    }
    
    mutating func createFolder(path: String) throws {
        let fm = FileManager.default
        let dirPath = "\(siteDir)/\(path)"
        try fm.copyItem(atPath: "\(folder)/\(path)", toPath: dirPath)
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
        let body = try markup.html()
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
        let title = path
            .replacingOccurrences(of: ".html", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
        let header = try getHeader(frontMatter: ["title": title])
        let footer = try getFooter(frontMatter: [:])
        var newString = """
\(header)
\(string)
\(footer)
"""
        newString = try template(input: newString, frontMatter: [:], styleSheets: styleSheets, scripts: scripts)
        try newString.write(toFile: "\(siteDir)/\(path)", atomically: true, encoding: .utf8)
    }
    
    mutating func createBlog() throws {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: "\(folder)/posts", isDirectory: &isDir) && isDir.boolValue {
            let postTemplate = try String(contentsOfFile: "\(folder)/post.html", encoding: .utf8)
            try createPosts()
            let postString = try posts
                .map {
                    let post = try String(contentsOfFile: "\(folder)/posts/\($0)", encoding: .utf8)
                    //TODO: allow just getting front matter without parsing whole file
                    let frontMatter = try MarkMark.parse(post).frontMatter
                    let template = try template(input: postTemplate, frontMatter: frontMatter, styleSheets: [], scripts: [])
                    return template
                }
                .joined(separator: "\n")
            let body = """
\(postString)
"""
            let header = try getHeader(frontMatter: ["title": "blog"])
            let footer = try getFooter(frontMatter: [:])
            let contents = """
\(header)
\(body)
\(footer)
"""
            fm.createFile(atPath: "\(siteDir)/blog.html", contents: contents.data(using: .utf8))
        }
    }
    
    func createPosts() throws {
        for post in posts {
            let fm = FileManager.default
            let input = try String(contentsOfFile: "\(folder)/posts/\(post)", encoding: .utf8)
            let markup = try MarkMark.parse(input)
            let body = try markup.html()
            let header = try getHeader(frontMatter: markup.frontMatter)
            let footer = try getFooter(frontMatter: markup.frontMatter)
            
            let html = """
\(header)
\(body)
\(footer)
"""
            
            let data = html.data(using: .utf8)
            let htmlPath = post.replacingOccurrences(of: ".md", with: ".html")
            fm.createFile(atPath: "\(siteDir)/\(htmlPath)", contents: data)
        }
    }
}
