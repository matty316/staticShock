//
//  StaticShock.swift
//  StaticShock
//
//  Created by Matthew Reed on 12/11/24.
//

import Foundation
import ArgumentParser
import MarkyMark

@main
struct StaticShock: ParsableCommand {
    @Argument var folder: String
    
    func run() throws {
        let fm = FileManager.default
        let paths = try fm.contentsOfDirectory(atPath: folder)
        try Generator(folder: folder).create(paths: paths)
    }
}
