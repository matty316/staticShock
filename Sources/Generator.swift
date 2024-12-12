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
    let header = """
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>HTML 5 Boilerplate</title>
    <link rel="stylesheet" href="style.css">
  </head>
  <body>
"""
    let footer = """
  </body>
</html>
"""
    
    func create(paths: [String]) throws {
        let fm = FileManager.default
        try fm.createDirectory(atPath: siteDir, withIntermediateDirectories: true)
        for path in paths {
            if path.hasSuffix(".md") {
                try createFile(path: path)
            } else {
                try createFolder(path: path)
            }
        }
    }
    
    func createFolder(path: String) throws {
        let fm = FileManager.default
        try fm.createDirectory(atPath: "\(siteDir)/\(path)", withIntermediateDirectories: true)
    }
    
    func createFile(path: String) throws {
        let fm = FileManager.default
        let input = try String(contentsOfFile: "\(folder)/\(path)", encoding: .utf8)
        let markup = try MarkMark.parse(input)
        let body = markup.html()
        
        let html = """
\(header)
\(body)
\(footer)
"""
        
        let data = html.data(using: .utf8)
        let htmlPath = path.replacingOccurrences(of: ".md", with: ".html")
        fm.createFile(atPath: "\(siteDir)/\(htmlPath)", contents: data)
    }
}
